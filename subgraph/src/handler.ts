import { BigInt, BigDecimal, Bytes, ethereum, log, Address, dataSource } from "@graphprotocol/graph-ts"
import { getUsdPrice } from "./prices"
import {ETH_ADDRESS}  from "./prices/config/mainnet";

import {
  OwnershipTransferred as OwnershipTransferredEvent,
  PaymentReceived as PaymentReceivedEvent,
  Withdrawal as WithdrawalEvent
} from "../generated/Schnaps/Schnaps"
import {
  OwnershipTransferred,
  PaymentReceived,
  Withdrawal
} from "../generated/schema"

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handlePaymentReceived(event: PaymentReceivedEvent): void {
  let entity = new PaymentReceived(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )

  let usdValue = BigDecimal.fromString("1234")
  if (event.params.token == Address.zero()) {
    usdValue = getUsdPrice(ETH_ADDRESS, bigIntToBigDecimal(event.params.amount))
  } else if (event.params.token == Address.fromString("0x2791bca1f2de4661ed88a30c99a7a9449aa84174")) {
    usdValue = getUsdPrice(event.params.token, bigIntToBigDecimal(event.params.amount, 6))
  } else {
    usdValue = getUsdPrice(event.params.token, bigIntToBigDecimal(event.params.amount))
  }

  entity.network = dataSource.network()
  entity.sender = event.params.sender
  entity.token = event.params.token
  entity.amount = event.params.amount
  entity.usdValue = usdValue
  entity.barcode = event.params.barcode.toString()

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleWithdrawal(event: WithdrawalEvent): void {
  let entity = new Withdrawal(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.receiver = event.params.recipient
  entity.token = event.params.token
  entity.amount = event.params.amount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function bigIntToBigDecimal(
  quantity: BigInt,
  decimals: i32 = 18
): BigDecimal {
  return quantity.divDecimal(
    BigInt.fromI32(10)
      .pow(decimals as u8)
      .toBigDecimal()
  );
}
