enum ACCOUNT { BTC, ETH, XRP }

const Map ACCOUNT_LIST = {
  ACCOUNT.BTC: {
    'cointype': 0,
    'purpose': 44,
    'symbol': 'BTC',
    'imgPath': 'assets/images/btc.png',
    'accountType': ACCOUNT.BTC
  },
  ACCOUNT.ETH: {
    'cointype': 60,
    'purpose': 44,
    'symbol': 'ETH',
    'imgPath': 'assets/images/eth.png',
    'accountType': ACCOUNT.ETH
  },
  ACCOUNT.XRP: {
    'cointype': 144,
    'purpose': 44,
    'symbol': 'XRP',
    'imgPath': 'assets/images/xrp.png',
    'accountType': ACCOUNT.XRP
  }
};
