import requests
import pandas as pd


url = "https://api.quiverquant.com/beta/live/housetrading"

auth_string = "Bearer 0e34403a431d7950fc588a26090b9729c2714d5d"

headers = {
    "Accept": "application/json",
    "Authorization": auth_string
}

response = requests.get(url, headers=headers)
df = pd.DataFrame(response.json())

print(len(df))
print(df.columns)



