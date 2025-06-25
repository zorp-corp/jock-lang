use nockapp::driver::Operation;
use nockapp::{kernel::boot, noun::slab::NounSlab};
use nockapp::{one_punch_driver, Noun, AtomExt};
use nockvm::noun::{Atom, D, T};
use nockvm_macros::tas;

use clap::{arg, command, ColorChoice, Parser};
static KERNEL_JAM: &[u8] =
    include_bytes!(concat!(env!("CARGO_WORKSPACE_DIR"), "/assets/jockc.jam"));

use nockapp::kernel::boot::Cli as BootCli;

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

    #[arg(
        long = "import-dir",
        help = "Supply a path for library imports",
        num_args = 1
    )]
    lib_path: Option<String>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = TestCli::parse();

    let mut nockapp:nockapp::NockApp = boot::setup(
        KERNEL_JAM,
        Some(cli.boot.clone()),
        &[],
        "jockc",
        None,
    )
    .await?;
    boot::init_default_tracing(&cli.boot.clone());

    let mut slab = NounSlab::new();

    let poke = {
        // Acquire name.
        let string = cli.name_.unwrap_or("".to_string());
        let name = Atom::from_value(&mut slab, string.clone()).unwrap().as_noun().as_atom().unwrap();

        // Acquire file text.
        println!("Reading file: {}.jock", string);
        let text = std::fs::read_to_string(format!("{}.jock", string))
            .expect("Unable to read file");
        let text = Atom::from_value(&mut slab, text).unwrap().as_noun().as_atom().unwrap();

        // Convert args to a Hoon list.
        let args = vec_to_hoon_list(&mut slab, cli.args_);

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
                                    // lib_names.push(lib_name);
                                    // Read file content.
                                    let lib_text = std::fs::read_to_string(&path)
                                        .expect("Unable to read library file");
                                    let _lib_text = Atom::from_value(&mut slab, lib_text.clone())
                                        .unwrap()
                                        .as_noun()
                                        .as_atom()
                                        .unwrap();
                                    // lib_texts.push(T(&mut slab, &[lib_name, _lib_text]));
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

        let tuple = vec_to_hoon_tuple_list(&mut slab, lib_texts);

        slab.modify(|_root|
            { vec![D(tas!(b"jock")),
                name.as_noun(),
                text.as_noun(),
                args,
                tuple] });
        slab
    };

    nockapp
        .add_io_driver(one_punch_driver(poke, Operation::Poke))
        .await;

    nockapp.run().await?;

    Ok(())
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
