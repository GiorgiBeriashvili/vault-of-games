use std::{fs::File, io::Read};

use anyhow::Result;
use jwt_simple::prelude::{Ed25519KeyPair, Ed25519PublicKey};
use once_cell::sync::Lazy;

enum KeyType {
    Private,
    Public,
}

impl std::fmt::Display for KeyType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                KeyType::Private => "private.key",
                KeyType::Public => "public.key",
            }
        )
    }
}

pub struct KeyPair {
    pub private_key: Ed25519KeyPair,
    pub public_key: Ed25519PublicKey,
}

impl KeyPair {
    pub fn new(private_key: Ed25519KeyPair, public_key: Ed25519PublicKey) -> Self {
        Self {
            private_key,
            public_key,
        }
    }

    fn from_key_files() -> Result<Self> {
        let mut buffer = Vec::new();

        File::open(KeyType::Private.to_string())?.read_to_end(&mut buffer)?;

        let private_key = Ed25519KeyPair::from_bytes(&buffer)?;

        buffer.clear();

        File::open(KeyType::Public.to_string())?.read_to_end(&mut buffer)?;

        let public_key = Ed25519PublicKey::from_bytes(&buffer)?;

        Ok(Self::new(private_key, public_key))
    }
}

pub static LAZY_KEYPAIR: Lazy<KeyPair> =
    Lazy::new(|| KeyPair::from_key_files().expect("Failed to read key files."));
