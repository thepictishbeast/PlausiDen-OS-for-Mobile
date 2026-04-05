//! Brain Protection Domain — LFI engine integration for PlausiDenOS.
//!
//! Runs the neurosymbolic AI engine, makes real-time data pollution decisions,
//! manages device keys, and controls swarm participation. This is the intelligence
//! layer of the plausible deniability system.
//!
//! NOTE: This is NOT related to plausiden-vault/plausiden-shield infrastructure repos.
//! Brain PD runs on a phone inside seL4, not on a server.
pub mod engine;
pub mod strategy;
pub mod swarm_client;
pub mod translator;
pub mod key_management;
pub mod android_bridge;
pub mod config;
