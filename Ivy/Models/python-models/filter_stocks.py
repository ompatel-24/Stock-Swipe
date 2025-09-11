import yfinance as yf
from user_vector import user_industry

def full_stocks_list(tickers, user_vector):
    """
    Returns only the tickers whose sector matches the user's selected sectors
    """
    preferred_sectors = user_industry(user_vector)
    relevant_stocks = []

    for ticker in tickers:
        try:
            stock = yf.Ticker(ticker)
            sector = stock.info.get("sector", None)
            if sector and sector in preferred_sectors:
                relevant_stocks.append(ticker)
        except Exception as e:
            print(f"Error fetching {ticker}: {e}")
            continue

    return relevant_stocks

if __name__ == "__main__":
    print("")