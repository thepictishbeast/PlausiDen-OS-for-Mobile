//! Vault Protection Domain — deniable encrypted storage for PlausiDenOS.
//!
//! Manages multiple encrypted personalities, each with its own filesystem,
//! contacts, messages, and behavioral profile. Only one personality is active
//! at a time. Others are indistinguishable from random data.
//!
//! Features: duress PIN (activates decoy), Scorched Earth (destroys all key material),
//! ZKP identity proofs, LFI-generated activity for each personality.
//!
//! NOTE: This is NOT plausiden-vault (infrastructure). That manages Vaultwarden
//! passwords for servers. Vault PD manages encrypted phone personalities.
pub mod personality;
pub mod storage;
pub mod encryption;
pub mod key_derivation;
pub mod duress;
pub mod scorched_earth;
pub mod zkp_identity;
pub mod mount;
pub mod config;
