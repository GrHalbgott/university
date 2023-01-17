import numpy as np

def test_me():

    for i in range(6):
        x = list(range(10**7))
        y = np.random.uniform(0, 100, size=(10**7))
        y = y.tolist()

if __name__ == "__main__":
   test_me()
