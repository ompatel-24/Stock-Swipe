def create_user_vector(
    risk_tolerance,
    investment_horizon_years,
    investment_amount,
    liquidity_needs,
    industry_sectors
):
    user_vector = [
        risk_tolerance,
        investment_horizon_years / 30,
        investment_amount / 1e6,
        liquidity_needs,
        industry_sectors
    ]
    return user_vector

def user_industry(user_vector):
    return user_vector[-1]

if __name__ == "__main__":
    print("")