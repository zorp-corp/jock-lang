use nockapp::driver::Operation;
use nockapp::kernel::boot;
use nockapp::noun::slab::NounSlab;
use nockapp::{one_punch_driver, Noun, AtomExt};
use nockvm::noun::{Atom, D, T};
use nockvm_macros::tas;

use clap::{arg, command, ColorChoice, Parser};
static KERNEL_JAM: &[u8] = include_bytes!(concat!(env!("CARGO_WORKSPACE_DIR"), "assets/jockt.jam"));

use nockapp::kernel::boot::Cli as BootCli;

#[derive(Parser, Debug)]
#[command(about = "Execs various poke types for the kernel", author = "zorp", version, color = ColorChoice::Auto)]
struct ExecCli {
    #[command(flatten)]
    boot: BootCli,

    #[command(subcommand)]
    command: Command,

    #[arg(
        long = "import-dir",
        help = "Supply a path for library imports",
        num_args = 1,
        global = true
    )]
    lib_path: Option<String>,
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

    let mut nockapp =
        boot::setup(KERNEL_JAM, Some(cli.boot.clone()), &[], "jockt", None).await?;

    boot::init_default_tracing(&cli.boot.clone());
    let mut slab = NounSlab::new();

    // Load libraries from path if provided.
    let lib_path = cli.lib_path.unwrap_or("lib_path".to_string());
    // Get names of all Hoon and Jock files in that directory.
    let mut lib_texts:Vec<(Atom,Atom)> = Vec::new();
    if let Ok(entries) = std::fs::read_dir(lib_path) {
        for entry in entries {
            if let Ok(entry) = entry {
                let path = entry.path();
                if let Some(ext) = path.extension() {
                    if ext == "hoon" || ext == "jock" || ext == "txt" {  // XXX kludge for now on txt
                        if let Some(stem) = path.file_stem() {
                            if let Some(stem_str) = stem.to_str() {
                                let lib_name = Atom::from_value(&mut slab, stem_str.to_string())
                                    .unwrap()
                                    .as_noun()
                                    .as_atom()
                                    .unwrap();
                                // Read file content.
                                let lib_text = std::fs::read_to_string(&path)
                                    .expect("Unable to read library file");
                                let _lib_text = Atom::from_value(&mut slab, lib_text.clone())
                                    .unwrap()
                                    .as_noun()
                                    .as_atom()
                                    .unwrap();
                                lib_texts.push((lib_name, _lib_text));
                                println!("Loaded library: {}", stem_str);
                            }
                        }
                    }
                }
            }
        }
    }
    println!("Found {} library files", lib_texts.len());
    if lib_texts.len() > 0 {
        let tuple = vec_to_hoon_tuple_list(&mut slab, lib_texts);

        slab.modify(|_root| { vec![D(tas!(b"loadlibs")), tuple] });

        nockapp
            .add_io_driver(one_punch_driver(slab, Operation::Poke))
            .await;
    }

    let poke = match cli.command {
        Command::Exec { n } => {
            let n = n.unwrap_or(0);
            create_poke(&[D(tas!(b"exec")), D(n)])
        }
        Command::ExecAll {} => {
            create_poke(&[D(tas!(b"exec-all")), D(0)])
        }
        Command::Test { n } => {
            let n = n.unwrap_or(0);
            create_poke(&[D(tas!(b"test")), D(n)])
        }
        Command::TestAll {} => {
            create_poke(&[D(tas!(b"test-all")), D(0)])
        }
        Command::ParseAll {} => {
            create_poke(&[D(tas!(b"parseall")), D(0)])
        }
        Command::JeamAll {} => {
            create_poke(&[D(tas!(b"jeam-all")), D(0)])
        }
        Command::MintAll {} => {
            create_poke(&[D(tas!(b"mint-all")), D(0)])
        }
        Command::JypeAll {} => {
            create_poke(&[D(tas!(b"jype-all")), D(0)])
        }
        Command::NockAll {} => {
            create_poke(&[D(tas!(b"nock-all")), D(0)])
        }
        Command::RunDetails {} => {
            create_poke(&[D(tas!(b"run")), D(0)])
        }
    };

    nockapp
        .add_io_driver(one_punch_driver(poke, Operation::Poke))
        .await;

    nockapp.run().await?;
    println!("Nock app run completed successfully");

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
pub fn vec_to_hoon_tuple_list(slab: &mut NounSlab, vec: Vec<(Atom,Atom)>) -> Noun {
    let mut list = D(0);
    for (a,b) in vec.iter().rev() {
        let n1 = a.as_noun();
        let n2 = b.as_noun();
        let tuple = T(slab, &[n1, n2]);
        list = T(slab, &[tuple, list]);
    }
    list
}
