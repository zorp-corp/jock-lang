use crown::kernel::boot;
use crown::kernel::form::Kernel;
use crown::utils::make_tas;
use crown::Noun;
use sword::noun::{D, T};
use sword_macros::tas;
use tracing::debug;

use clap::{arg, command, ColorChoice, Parser};
static KERNEL_JAM: &[u8] = include_bytes!(concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/assets/jocktest.jam"
));

use crown::kernel::boot::Cli as BootCli;

#[derive(Parser, Debug)]
#[command(about = "Tests various poke types for the kernel", author = "zorp", version, color = ColorChoice::Auto)]
struct TestCli {
    #[command(flatten)]
    boot: BootCli,

    #[command(subcommand)]
    command: Command,
}

#[derive(Parser, Debug)]
enum Command {
    #[command(about = "Test n with optional override")]
    TestN {
        #[arg(help = "The number to test")]
        n: Option<u64>,
    },
    #[command(about = "Test all with optional override")]
    TestAll {
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = TestCli::parse();
    let mut nockapp = boot::setup(KERNEL_JAM, Some(cli.boot), &[], "jock")?;

    let poke = match cli.command {
        Command::TestN { n } => {
            let n = n.unwrap_or(0); // Default to 0 if not provided
            create_poke(&mut nockapp.kernel, &[D(tas!(b"test-n")), D(n)])
        }
        Command::TestAll { } => {
            let tas = make_tas(nockapp.kernel.serf.stack(), "test-all");
            create_poke(&mut nockapp.kernel, &[tas.as_noun(), D(0)])
        }
    };

    debug!("Sending poke: {:?}", poke);
    let poke_result = nockapp.kernel.poke(poke)?;
    debug!("Poke response: {:?}", poke_result);

    Ok(())
}

fn create_poke(kernel: &mut Kernel, args: &[Noun]) -> Noun {
    // error if args is less than 2 elements
    if args.len() < 2 {
        panic!("args must have at least 2 elements");
    }
    T(kernel.serf.stack(), args)
}

