
__author__ = 'SJeffers'

import sys

def makeChange(diffCoinValues, totalValue):
    ''' Function that determines the minumum amount of coins to make change. '''
    numCoins = [0] + [sys.maxsize-1]*totalValue
    index = [0] + [-1]*totalValue

    #Go through every value from 1-A for each coin
    for j in range(len(diffCoinValues)):
        for i in range(1, totalValue+1):
            #if the value is greater or equal to the denomination of the current coin
            if i >= diffCoinValues[j]:
                #if the new number of coins it takes to make a value is smaller than the old one
                if numCoins[i-diffCoinValues[j]] + 1 < numCoins[i]:
                    #replace the number of coins it takes to make a value
                    numCoins[i] = numCoins[i-diffCoinValues[j]] + 1
                    #store the index of the last coin used to make the value
                    index[i] = j
    numOfEachCoin = []
    #this array will tell us how many of each coin was used
    for i in range(0,len(diffCoinValues)):
        numOfEachCoin.append(0)
    tempTotal = totalValue
    #trace backwards to figure out the count of each coin used.
    while tempTotal != 0:
        numOfEachCoin[index[tempTotal]] += 1
        tempTotal = tempTotal - diffCoinValues[index[tempTotal]]
    return numOfEachCoin, numCoins[totalValue]


if __name__ == '__main__':
    with open('amount.txt', 'r') as myFile:
        with open('change.txt', 'w') as myOutFile:
            for line in myFile:
                nums = line.strip('\n').strip('\r').split(' ')
                denomination = [int(l) for l in nums if l]
                amount = int(next(myFile))
                numOfEachCoin, coinCount = makeChange(denomination, amount)

                myOutFile.write(line)
                myOutFile.write(str(amount) + '\n')
                myOutFile.write(' '.join(map(str, numOfEachCoin)) + '\n')
                myOutFile.write(str(coinCount) + '\n')
