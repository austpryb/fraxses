// (c) 2019-2020, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

package snowman

// Factory returns new instances of Consensus
type Factory interface {
	New() Consensus
}
