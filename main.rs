use crown::nockapp::driver::Operation;
use crown::utils::make_tas;
use crown::{kernel::boot, noun::slab::NounSlab};
use crown::{one_punch_driver, Noun};
use sword::noun::{D, T};
use sword_macros::tas;

use clap::{arg, command, ColorChoice, Parser};
static KERNEL_JAM: &[u8] =
    include_bytes!(concat!(env!("CARGO_MANIFEST_DIR"), "/assets/jocktest.jam"));

use crown::kernel::boot::Cli as BootCli;

#[derive(Parser, Debug)]
#[command(about = "Execs various poke types for the kernel", author = "zorp", version, color = ColorChoice::Auto)]
struct ExecCli {
    #[command(flatten)]
    boot: BootCli,

    #[command(subcommand)]
    command: Command,
}

#[derive(Parser, Debug)]
enum Command {
    #[command(about = "The name of the code to run")]
    Exec {
        #[arg(help = "The name of the code to run")]
        n: Option<u64>,
    },
    #[command(about = "Execute all")]
    ExecAll {},
    #[command(about = "The name of the code to test")]
    Test {
        #[arg(help = "The name of the code to test")]
        n: Option<u64>,
    },
    #[command(about = "Test all")]
    TestAll {},
    #[command(about = "Parse all")]
    ParseAll {},
    #[command(about = "Jeam all")]
    JeamAll {},
    #[command(about = "Mint all")]
    MintAll {},
    #[command(about = "Jype all")]
    JypeAll {},
    #[command(about = "Run all Nock")]
    NockAll {},
    #[command(about = "Run details")]
    RunDetails {},
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = ExecCli::parse();

    let mut nockapp = boot::setup(
        KERNEL_JAM,
        Some(cli.boot.clone()),
        &[],
        "jocktest",
        None,
    )
    .await?;

    boot::init_default_tracing(&cli.boot.clone());

    let poke = match cli.command {
        Command::Exec { n } => {
            let n = n.unwrap_or(0);
            create_poke(&[D(tas!(b"exec")), D(n)])
        }
        Command::ExecAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "exec-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::Test { n } => {
            let n = n.unwrap_or(0);
            create_poke(&[D(tas!(b"test")), D(n)])
        }
        Command::TestAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "test-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::ParseAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "parse-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::JeamAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "jeam-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::MintAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "mint-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::JypeAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "jype-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::NockAll {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "nock-all");
            create_poke(&[tas.as_noun(), D(0)])
        }
        Command::RunDetails {} => {
            let mut slab = NounSlab::new();
            let tas = make_tas(&mut slab, "run-details");
            create_poke(&[tas.as_noun(), D(0)])
        }
    };

    nockapp
        .add_io_driver(one_punch_driver(poke, Operation::Poke))
        .await;

    nockapp.run().await?;

    Ok(())
}

fn create_poke(args: &[Noun]) -> NounSlab {
    if args.len() < 2 {
        panic!("args must have at least 2 elements");
    }
    let mut slab = NounSlab::new();
    let copy_root = T(&mut slab, args);
    slab.copy_into(copy_root);
    slab
}
