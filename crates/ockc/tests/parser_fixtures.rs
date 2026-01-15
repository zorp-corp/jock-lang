use std::collections::HashSet;
use std::fs;
use std::path::Path;

use ockc::parse;

#[test]
fn parses_jock_fixtures() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("crates")
        .join("jockt")
        .join("hoon")
        .join("lib")
        .join("tests");

    let mut skip = HashSet::new();
    skip.insert("baby.jock");

    let entries = fs::read_dir(&root).expect("read fixtures");
    for entry in entries {
        let entry = entry.expect("fixture entry");
        let path = entry.path();
        if path.extension().and_then(|ext| ext.to_str()) != Some("jock") {
            continue;
        }
        if let Some(name) = path.file_name().and_then(|name| name.to_str()) {
            if skip.contains(name) {
                continue;
            }
        }
        let source = fs::read_to_string(&path).expect("fixture contents");
        let result = parse(&source);
        assert!(
            result.is_ok(),
            "failed to parse {}: {:?}",
            path.display(),
            result.err()
        );
    }
}

#[test]
fn parses_dollar_recur() {
    let result = parse("$(foo)");
    assert!(
        result.is_ok(),
        "failed to parse $ recur: {:?}",
        result.err()
    );
}

#[test]
fn parses_eval_expr() {
    let result = parse("eval(foo)(bar)");
    assert!(result.is_ok(), "failed to parse eval: {:?}", result.err());
}

#[test]
fn rejects_hyphenated_identifiers() {
    let result = parse("let foo-bar = 1; foo");
    assert!(result.is_err(), "expected hyphenated name to error");
    let errors = result.err().expect("errors");
    assert!(!errors.is_empty(), "expected at least one error");
}
