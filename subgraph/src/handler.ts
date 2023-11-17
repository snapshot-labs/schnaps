import { BigInt, BigDecimal, Bytes, ethereum, log, Address, dataSource } from "@graphprotocol/graph-ts"
import { getUsdPrice } from "./prices"
import {WETH_ADDRESS, WETH_TOKEN_DECIMALS, ETH_ADDRESS, WMATIC_TOKEN_DECIMALS,USDC_ADDRESS, USDC_E_ADDRESS, USDC_TOKEN_DECIMALS}  from "./prices/config/polygon";

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

  let usdValue = getUsdValue(event.params.token, event.params.amount)

  let encoded = event.params.barcode.toString()
  let chunks = encoded.split(":")

  entity.network = dataSource.network()
  entity.sender = event.params.sender
  entity.token = event.params.token
  entity.amount = event.params.amount
  entity.usdValue = usdValue
  entity.barcode = chunks[0]

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

function getUsdValue(token: Address, amount: BigInt): BigDecimal {
  let usdValue = BigDecimal.fromString("0")
  if (token == Address.zero() || token == WETH_ADDRESS) {
    // Token is MATIC/WMATIC
    // TODO: rename WETH_ADDRESS to WMATIC_ADDRESS
    usdValue = getUsdPrice(WETH_ADDRESS, bigIntToBigDecimal(amount, WMATIC_TOKEN_DECIMALS))
  } else if (token == USDC_ADDRESS || token == USDC_E_ADDRESS) {
    // Token is USDC/USDC.e
    usdValue = getUsdPrice(USDC_E_ADDRESS, bigIntToBigDecimal(amount, USDC_TOKEN_DECIMALS))
  } else if (token == ETH_ADDRESS) {
    // Token is WETH
    usdValue = getUsdPrice(ETH_ADDRESS, bigIntToBigDecimal(amount, 18))
  }
  // If the token is unknown, it will be priced  at zero
  return usdValue
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
