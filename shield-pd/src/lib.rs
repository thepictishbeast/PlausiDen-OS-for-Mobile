//! Shield Protection Domain — network defense layer for PlausiDenOS.
//!
//! All outbound network traffic passes through Shield PD before reaching
//! the network hardware. Intercepts packets, injects noise, diversifies
//! TLS fingerprints, and detects forensic tools in the Android VM.
//!
//! NOTE: This is NOT the plausiden-shield infrastructure ops dashboard.
//! Shield PD intercepts network packets on a phone. The infra shield monitors servers.
pub mod network_filter;
pub mod dns_pollution;
pub mod tls_diversify;
pub mod data_inspector;
pub mod traffic_injector;
pub mod forensic_detector;
pub mod vpn_manager;
pub mod config;
