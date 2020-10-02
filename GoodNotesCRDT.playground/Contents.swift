import UIKit

// Implementation of CRDT (LWW-Element-Set) in Swift.
//
// Task:
//  - store a timestamp for each entry
//  - `add` and `remove` operations
//  - allow updating of the value
//  - function to merge two dictionaries
//  - test cases should be clearly written and document what aspect of CRDT they test
//
// Used sources:
// - https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#LWW-Element-Set_(Last-Write-Wins-Element-Set)
// - https://www.serverless.com/blog/crdt-explained-supercharge-serverless-at-edge (video)
// - https://developer.apple.com/documentation/swift/set (terminology)
// - https://bartoszsypytkowski.com/the-state-of-a-state-based-crdts/

struct CRDTLWWElementSet<Element: Hashable> {

    // MARK: - Properties

    private(set) var addDictionary: [Element: Date] = [:]
    private(set) var removeDictionary: [Element: Date] = [:]

    // MARK: - Read

    mutating func lookupTimestampForElement(_ element: Element) -> Date? {
        guard let addTimestamp = addDictionary[element] else {
            return nil
        }
        if let removeTimestamp = removeDictionary[element] {
            return addTimestamp > removeTimestamp ? addTimestamp : nil
        } else {
            return addTimestamp
        }
    }

    // MARK: - Write

    // Custom timestamp is purely for testing purposes.

    mutating func addElement(_ element: Element, customTimestamp: Date = Date()) {
        if let recentAddTimestamp = lookupTimestampForElement(element), recentAddTimestamp >= Date() {
            return
        }
        addDictionary[element] = customTimestamp
    }

    mutating func removeElement(_ element: Element, customTimestamp: Date = Date()) {
        guard addDictionary[element] != nil else {
            return
        }
        removeDictionary[element] = customTimestamp
    }

    mutating func merge(_ setToBeMerged: CRDTLWWElementSet) {
        addDictionary.merge(setToBeMerged.addDictionary, uniquingKeysWith: { current, new in max(current, new) })
        removeDictionary.merge(setToBeMerged.removeDictionary, uniquingKeysWith: { current, new in max(current, new) })
    }
}

extension CRDTLWWElementSet: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.addDictionary == rhs.addDictionary && lhs.removeDictionary == rhs.removeDictionary
    }
}

// TESTS

let now = Date()
let testingTimestamps = (1...5).compactMap { Calendar.current.date(byAdding: .minute, value: $0, to: now) }

// Tests 1/2: Operations on single set

// Add element two different elements at the same timestamp
var setA = CRDTLWWElementSet<Int>()
setA.addElement(1, customTimestamp: testingTimestamps[0])
setA.addElement(2, customTimestamp: testingTimestamps[0])
assert(setA.lookupTimestampForElement(1) == testingTimestamps[0], "Added element not found")
assert(setA.lookupTimestampForElement(2) == testingTimestamps[0], "Added element not found")
assert(setA.lookupTimestampForElement(22) == nil, "This element wasn't added, response should be nil")
assert(setA.addDictionary.count == 2, "Unresolved conflict")

// Simulate conflict
setA.addElement(1, customTimestamp: testingTimestamps[0])
assert(setA.addDictionary.count == 2, "Unresolved conflict")

// Remove element
setA.removeElement(1, customTimestamp: testingTimestamps[0])
assert(setA.lookupTimestampForElement(1) == nil, "Removing failed")

// Tests 2/2: Merging

var setB = CRDTLWWElementSet<Int>()
var setC = CRDTLWWElementSet<Int>()

// Merge non-empty set into empty set
setB.addElement(1, customTimestamp: testingTimestamps[0])
setB.addElement(2, customTimestamp: testingTimestamps[1])
setB.addElement(3, customTimestamp: testingTimestamps[2])
setB.addElement(4, customTimestamp: testingTimestamps[3])
setB.removeElement(4, customTimestamp: testingTimestamps[3])
setC.merge(setB)
assert(setB == setC, "Unsuccessful merge")

// Now remove something from both (B & C) sets, then merge
setB.removeElement(1, customTimestamp: testingTimestamps[0])
setC.removeElement(2, customTimestamp: testingTimestamps[1])
setC.merge(setB)
assert(setC.lookupTimestampForElement(1) == nil, "1 was removed from B and merged into C - must be nil")
assert(setC.lookupTimestampForElement(2) == nil, "2 was removed C and B was merged into C - must be nil")
assert(setB.lookupTimestampForElement(2) != nil, "2 was removed from C, but B was merged into C so B should still have it - mustn't be nil")
