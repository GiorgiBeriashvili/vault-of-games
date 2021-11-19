use std::{
    collections::HashMap,
    sync::{Arc, RwLock},
};

pub type Database<Key, Value> = Arc<RwLock<HashMap<Key, Value>>>;
