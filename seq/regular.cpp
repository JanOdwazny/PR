#include <iostream>
#include <vector>
#include <algorithm>
#include <random>
#include <time.h>
#include <chrono>



using namespace std::chrono;



int knapsack(int cap, int weights[], int values[], int n)
{
    std::vector<std::vector<int>> dp(n + 1, std::vector<int>(cap + 1, 0));
    
    for (int i = 1; i <= n; i++)
    {
        for (int j = 1; j <= cap; j++)
        {
            if (weights[i - 1] <= j)
            {
                dp[i][j] = std::max(dp[i - 1][j], dp[i - 1][j - weights[i - 1]] + values[i - 1]);
            }
            else
            {
                dp[i][j] = dp[i - 1][j];
            }
        }
    }
    
    return dp[n][cap];
    
}
int CAPACITY[] = {10000, 20000, 30000, 40000, 50000, 60000};
int NUM_ITEMS[] = {5000, 10000, 15000, 30000, 40000, 50000};
int main()
{
    
    
    srand(time(NULL));
    int maxValue = 0;

    
    for (int i = 0; i < 6; i++)
    {

        int num_items = NUM_ITEMS[i];
        int capacity = CAPACITY[1];

        int values[num_items] = {0};
        int weights[num_items] = {0};

        for (int j = 0; j < num_items; j++)
        {
            values[j] = rand() % 100 + 10;
            weights[j] = rand() % (capacity / 2) + 1;
        }

        auto start = high_resolution_clock::now();
        maxValue = knapsack(capacity, weights, values, num_items);
        auto stop = high_resolution_clock::now();

        auto duration = duration_cast<milliseconds>(stop - start);
        std::cout << capacity << ":" << num_items << ":" << duration.count() << std::endl;
}

    return 0;
}
