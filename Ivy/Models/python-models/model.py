import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from stock_swipes import batch_20_stocks, swipes
from user_vector import create_user_vector, user_industry
from stock_features import extract_stock_features

def update_user_vector(user_vector, batch_stocks, swipes):
    liked_vectors = [row.values for row, s in zip(batch_stocks.iterrows(), swipes) if s == 1]
    if not liked_vectors:
        return user_vector
    liked_array = np.vstack(liked_vectors)
    return np.mean(np.vstack([user_vector, liked_array]), axis=0)

def remove_seen_stocks(pool, batch_stocks):
    return pool.drop(batch_stocks.index)

def prepare_training_data(user_vector, batch_stocks, swipes):
    X, y = [], []
    for sv, s in zip(batch_stocks.iterrows(), swipes):
        # Ensure user_vector is 1D numeric array
        numeric_user_vector = np.array([v if isinstance(v, (int, float)) else 0 for v in user_vector])
        X.append(np.concatenate([numeric_user_vector, sv[1].values]))
        y.append(s)
    return np.array(X), np.array(y)

def train_rf(X, y):
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=None,
        random_state=42
    )
    model.fit(X, y)
    return model

def rank_next_batch(user_vector, pool_of_stock, model, top_n=20):
    prob_list = []
    for _, row in pool_of_stock.iterrows():
        numeric_user_vector = np.array([v if isinstance(v, (int, float)) else 0 for v in user_vector])
        X_input = np.concatenate([numeric_user_vector, row.values]).reshape(1, -1)
        prob_right = model.predict_proba(X_input)[0][1]
        prob_list.append(prob_right)
    ranked_pool = pool_of_stock.copy()
    ranked_pool['prob_right'] = prob_list
    ranked_pool = ranked_pool.sort_values(by='prob_right', ascending=False)
    return ranked_pool.head(top_n)

def simulate_or_get_swipes(batch_20_stocks):
    return np.random.choice([0, 1], size=len(batch_20_stocks)).tolist()

def run_iteration(user_vector, batch_20_stocks, swipes, pool_of_stock, all_X, all_y, top_n=20):
    """
    Runs a single iteration of the stock swipe pipeline:
    - Updates user vector from liked stocks
    - Prepares training data
    - Trains Random Forest
    - Removes seen stocks
    - Ranks next batch
    """
    # Prepare training data for this batch
    X_batch, y_batch = prepare_training_data(user_vector, batch_20_stocks, swipes)
    all_X.append(X_batch)
    all_y.append(y_batch)

    # Train Random Forest on all seen batches
    X_train = np.vstack(all_X)
    y_train = np.hstack(all_y)
    model = train_rf(X_train, y_train)

    # Update user vector based on liked stocks
    user_vector = update_user_vector(user_vector, batch_20_stocks, swipes)

    # Remove seen stocks from pool
    pool_of_stock = remove_seen_stocks(pool_of_stock, batch_20_stocks)

    # Rank next batch
    if len(pool_of_stock) > 0:
        batch_20_stocks = rank_next_batch(user_vector, pool_of_stock, model, top_n=top_n)
        swipes = simulate_or_get_swipes(batch_20_stocks)
    else:
        batch_20_stocks = pd.DataFrame()
        swipes = []

    return user_vector, pool_of_stock, batch_20_stocks, swipes, model

if __name__ == "__main__":
    print("Random Forest ML pipeline ready")