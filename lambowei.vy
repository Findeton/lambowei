#
# Ponzi art contract
#

Bid: event({value: wei_value, image: string[200], base: wei_value, target: wei_value, bidder: address, bidder_idx: indexed(address)})

# Owner address
owner: public(address) # = ZERO_ADDRESS

# Current state of auction
highestBidder: public(address)
highestBid: public(wei_value)
highestBidderImage: public(string[200])

base: public(wei_value)
target: public(wei_value)

@public
def __init__(_owner: address, _target: wei_value):
    assert _target > 0

    self.owner = _owner
    self.highestBidder = _owner
    self.target = _target
    self.base = _target / 4

@public
@payable
def bid(imgUrl: string[200]):
    # Check if bid is high enough
    assert msg.value >= self.target, "Required minimum bid value: target"

    # Check owner debt
    assert (self.balance - msg.value) >= self.base, "Required minimum contract balance: base"

    ratio: decimal = sqrt( convert(self.balance, decimal) / convert(self.base, decimal) )

    newRatio2: decimal = 4.0 * convert(msg.value, decimal) / convert(self.target, decimal)

    sendAmount: wei_value = as_wei_value(convert(self.base, decimal) * ratio, "wei")

    assert (self.balance - sendAmount > self.base), "Error calculating new base"

    send(self.highestBidder, sendAmount)

    self.base = self.balance
    self.target = as_wei_value(convert(self.base, decimal) * newRatio2, "wei")
    self.highestBidder = msg.sender
    self.highestBid = msg.value
    self.highestBidderImage = imgUrl

    log.Bid(msg.value, imgUrl, self.base, self.target, msg.sender, msg.sender)

@public
@payable
def ownerChange(_owner: address):
    # Check owner debt
    assert self.balance >= self.base, "Missing monies"

    # Check owner identity
    assert msg.sender == self.owner, "Only the owner can make this debt"

    self.owner = _owner


@public
@payable
def ownerDeposit():
    # Check owner identity
    assert msg.sender == self.owner

@public
@payable
def ownerWithdraw(quantity: wei_value):
    # Check owner identity
    assert msg.sender == self.owner, "Only the owner can withdraw"
    # Check balance
    assert self.balance >= quantity, "You can't withdraw more than the balance"
    send(self.owner, quantity)


