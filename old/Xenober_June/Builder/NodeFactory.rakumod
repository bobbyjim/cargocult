unit class Xenober15::Builder::NodeFactory;

use Xenober15::Node::Say;

method make-say(Match $/) {
	return Xenober16::Node::Say.new(
		expression => $<expression>.made
	);
}

method make-node(Match $match) {
	given $match {
		when .<say> {
			return Xenober16::Node::Say.new(
				expression => $match.<expression>.made
			);
		}
		default {
			die "No handler in NodeFactory for {$match.rule} at {$match}";
		}
	}
}
