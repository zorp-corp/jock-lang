use crown::nockapp::driver::Operation;
use crown::{kernel::boot, noun::slab::NounSlab};
use crown::{one_punch_driver, Noun, AtomExt};
use sword::noun::{Atom, D, T};
use sword_macros::tas;

use clap::{arg, command, ColorChoice, Parser};
static KERNEL_JAM: &[u8] =
    include_bytes!(concat!(env!("CARGO_WORKSPACE_DIR"), "/assets/jockc.jam"));

use crown::kernel::boot::Cli as BootCli;

#[derive(Parser, Debug)]
#[command(about = "Run Jock programs",
          author = "zorp",
          version,
          color = ColorChoice::Auto,
          arg_required_else_help = true
)]
struct TestCli {
    #[command(flatten)]
    boot: BootCli,

    #[arg(help = "Path to Jock file to compile and run")]
    name_: Option<String>,

    #[arg(
        // long,
        help = "Optional numeric arguments for the Jock file",
        num_args = 0..,
        value_delimiter = ' '
    )]
    args_: Vec<u64>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = TestCli::parse();

    let mut nockapp = boot::setup(
        KERNEL_JAM,
        Some(cli.boot.clone()),
        &[],
        "jockc",
        None,
    )
    .await?;
    boot::init_default_tracing(&cli.boot.clone());

    let poke = {
        // Acquire name.
        let string = cli.name_.unwrap_or("".to_string());
        let mut slab = NounSlab::new();
        let name = Atom::from_value(&mut slab, string.clone()).unwrap().as_noun().as_atom().unwrap();

        // Acquire file text.
        println!("Reading file: {}.jock", string);
        let text = std::fs::read_to_string(format!("{}.jock", string))
            .expect("Unable to read file");
        let text = Atom::from_value(&mut slab, text).unwrap().as_noun().as_atom().unwrap();

        // Convert args to a Hoon list.
        let args = vec_to_hoon_list(&mut slab, cli.args_);

        create_poke(&[
            D(tas!(b"jock")),
            T(&mut slab, &[name.as_noun(), text.as_noun(), args])
        ])
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

#[inline(always)]
pub fn hoon_list_to_vec(list: Noun) -> Vec<u64> {
    if list.is_atom() {
        if list.as_atom().unwrap().as_u64().unwrap() == 0 {
            return vec![];
        } else {
            panic!("Expected a list, but got an atom");
        }
    }

    let mut vec = Vec::new();
    let mut current = list;
    while current.is_cell() {
        let cell = current.as_cell().unwrap();
        vec.push(cell.head().as_atom().unwrap().as_u64().unwrap());
        current = cell.tail();
    }

    vec
}

#[inline(always)]
pub fn vec_to_hoon_list(slab: &mut NounSlab, vec: Vec<u64>) -> Noun {
    let mut list = D(0);
    for e in vec.iter().rev() {
        let n = Atom::new(slab, *e).as_noun();
        list = T(slab, &[n, list]);
    }
    list
}
