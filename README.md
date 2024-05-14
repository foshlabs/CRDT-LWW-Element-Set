# CRDT-LWW-Element-Set in Swift

## Overview

This project implements a Last-Write-Wins Element Set (LWW-Element-Set), a type of Conflict-free Replicated Data Type (CRDT), in Swift. CRDTs are data structures that power real-time collaborative applications by allowing multiple participants to make changes without the need for centralized coordination.

The `CRDTLWWElementSet` is designed to handle and resolve conflicts inherent in distributed systems, where updates might arrive out of order or at different times. The LWW strategy ensures that the most recent update (according to timestamps) prevails.

## Features

- **Timestamped Updates**: Each element in the set is associated with a timestamp that records the last update.
- **Add and Remove Operations**: Elements can be added to or removed from the set, with the state determined by comparing timestamps.
- **Conflict Resolution**: The implementation automatically resolves conflicts, favoring the most recent operation based on timestamps.
- **Merging**: Two LWW element sets can be merged, with element states resolved by the latest timestamps.

## Usage

The implementation allows for:
- Adding elements with optional custom timestamps for testing.
- Removing elements only if they exist and using timestamps for verification.
- Merging two LWW element sets into a single set with the most recent updates preserved.

## Testing

Test cases are included to validate basic operations, conflict resolution, and merging behavior, ensuring that the CRDT operates as expected under various scenarios.

## Resources

For more information on CRDTs and LWW-Element-Sets, visit:
- [Conflict-free replicated data type - Wikipedia](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#LWW-Element-Set_(Last-Write-Wins-Element-Set))
- [CRDT Explained - Supercharge Serverless at Edge](https://www.serverless.com/blog/crdt-explained-supercharge-serverless-at-edge)
- [Swift Set - Apple Developer Documentation](https://developer.apple.com/documentation/swift/set)
- [The State of a State-based CRDTs](https://bartoszsypytkowski.com/the-state-of-a-state-based-crdts/)
