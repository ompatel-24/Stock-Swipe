import yfinance as yf
import pandas as pd
import numpy as np

def extract_stock_features(tickers):
    """
    Returns a DataFrame of stock features for a list of tickers
    """
    data = []
    for ticker in tickers:
        try:
            stock = yf.Ticker(ticker)
            info = stock.info

            # Basic features
            pe_ratio = info.get("trailingPE", np.nan)
            pb_ratio = info.get("priceToBook", np.nan)
            eps = info.get("trailingEps", np.nan)
            div_yield = info.get("dividendYield", 0) or 0
            market_cap = info.get("marketCap", np.nan)
            revenue_growth = info.get("revenueGrowth", np.nan)
            profit_margin = info.get("profitMargins", np.nan)
            debt_equity = info.get("debtToEquity", np.nan)
            beta = info.get("beta", np.nan)

            # Historical volatility
            hist = stock.history(period="6mo")["Close"]
            log_returns = np.log(hist / hist.shift(1)).dropna()
            hist_vol = log_returns.std() * np.sqrt(252) if not log_returns.empty else np.nan

            features = {
                "ticker": ticker,
                "pe_ratio": pe_ratio,
                "pb_ratio": pb_ratio,
                "eps": eps,
                "div_yield": div_yield,
                "market_cap": market_cap,
                "revenue_growth": revenue_growth,
                "profit_margin": profit_margin,
                "debt_equity": debt_equity,
                "beta": beta,
                "hist_vol": hist_vol
            }

            data.append(features)
        except Exception as e:
            print(f"Error fetching {ticker}: {e}")
            continue

    return pd.DataFrame(data)

if __name__ == "__main__":
    print("")