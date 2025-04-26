---
title: cpp ps용 기본 문법 리마인드 💡
summary: 
date: 2025-04-26 23:54:47 +0900
lastmod: 2025-04-27 00:08:33 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# C++ Grammar and Syntax Guide for Coding Interviews (Algorithms & DS)

## Core Data Types and Variables

### Basic Types

```cpp
int x = 5;                  // Integer
long long bigNum = 1LL<<60; // Large integer (note LL suffix)
double y = 3.14;            // Double precision floating point
bool flag = true;           // Boolean
char c = 'A';               // Character
string s = "Hello";         // String (requires #include <string>)
```

### Type Modifiers

```cpp
unsigned int positiveOnly = 100;  // Only non-negative values
const int FIXED = 10;             // Cannot be modified after initialization
```

### Type Aliases

```cpp
typedef long long ll;              // Old style type alias
using ll = long long;              // Modern style type alias (preferred)
```

### Auto Type Deduction

```cpp
auto num = 10;                     // Compiler deduces type (int in this case)
auto it = myVector.begin();        // Iterator type automatically deduced
```

## Operators and Expressions

### Arithmetic Operators

```cpp
int a = 5 + 3;     // Addition: 8
int b = 5 - 3;     // Subtraction: 2
int c = 5 * 3;     // Multiplication: 15
int d = 5 / 3;     // Integer division: 1
int e = 5 % 3;     // Modulo (remainder): 2
double f = 5.0/3;  // Floating-point division: 1.6666...
```

### Compound Assignment

```cpp
a += 2;  // Same as a = a + 2
a -= 2;  // Same as a = a - 2
a *= 2;  // Same as a = a * 2
a /= 2;  // Same as a = a / 2
a %= 2;  // Same as a = a % 2
```

### Increment/Decrement

```cpp
int a = 5;
int b = ++a;  // Pre-increment: a becomes 6, b becomes 6
int c = a++;  // Post-increment: c becomes 6, then a becomes 7
int d = --a;  // Pre-decrement: a becomes 6, d becomes 6
int e = a--;  // Post-decrement: e becomes 6, then a becomes 5
```

### Comparison Operators

```cpp
bool isEqual = (a == b);       // Equal to
bool isNotEqual = (a != b);    // Not equal to
bool isGreater = (a > b);      // Greater than
bool isLess = (a < b);         // Less than
bool isGreaterEq = (a >= b);   // Greater than or equal to
bool isLessEq = (a <= b);      // Less than or equal to
```

### Logical Operators

```cpp
bool andResult = (a > 0 && b > 0);  // Logical AND (short-circuit)
bool orResult = (a > 0 || b > 0);   // Logical OR (short-circuit)
bool notResult = !a;                // Logical NOT
```

### Bitwise Operators

```cpp
int bitwiseAnd = a & b;    // Bitwise AND
int bitwiseOr = a | b;     // Bitwise OR
int bitwiseXor = a ^ b;    // Bitwise XOR
int bitwiseNot = ~a;       // Bitwise NOT
int leftShift = a << 2;    // Left shift (multiply by 2^2)
int rightShift = a >> 2;   // Right shift (divide by 2^2)
```

### Ternary Operator

```cpp
int max = (a > b) ? a : b;  // If a > b, max = a; otherwise max = b
```

## Control Flow

### Conditionals

```cpp
// If-else statement
if (x > 0) {
    cout << "Positive";
} else if (x < 0) {
    cout << "Negative";
} else {
    cout << "Zero";
}

// Switch statement
switch (x) {
    case 1:
        cout << "One";
        break;
    case 2:
        cout << "Two";
        break;
    default:
        cout << "Other";
}
```

### Loops

```cpp
// For loop
for (int i = 0; i < n; i++) {
    // Body
}

// Range-based for loop (C++11)
for (auto element : container) {
    // Process each element
}

// While loop
while (condition) {
    // Body
}

// Do-while loop
do {
    // Body
} while (condition);
```

### Loop Control

```cpp
for (int i = 0; i < n; i++) {
    if (condition1)
        continue;  // Skip current iteration
    
    if (condition2)
        break;     // Exit loop completely
}
```

## Functions

### Basic Function

```cpp
// Declaration and definition
int add(int a, int b) {
    return a + b;
}

// Usage
int sum = add(5, 3);  // sum = 8
```

### Default Parameters

```cpp
int multiply(int a, int b = 1) {
    return a * b;
}

int product1 = multiply(5);     // b defaults to 1, result = 5
int product2 = multiply(5, 3);  // b is 3, result = 15
```

### Function Overloading

```cpp
int max(int a, int b) {
    return (a > b) ? a : b;
}

double max(double a, double b) {
    return (a > b) ? a : b;
}
```

### Pass by Reference

```cpp
void swap(int& a, int& b) {
    int temp = a;
    a = b;
    b = temp;
}

int x = 5, y = 10;
swap(x, y);  // After this: x = 10, y = 5
```

### Lambda Functions (C++11)

```cpp
// Basic syntax: [capture](parameters) -> returnType { body }
auto add = [](int a, int b) -> int { return a + b; };

// Capture by value
int multiplier = 2;
auto multiply = [multiplier](int x) { return x * multiplier; };

// Capture by reference
auto increment = [&multiplier]() { multiplier++; };

// Capture all by value
auto lambda1 = [=]() { /* can use all variables by value */ };

// Capture all by reference
auto lambda2 = [&]() { /* can use all variables by reference */ };

// Capture specific variables with different methods
auto lambda3 = [x, &y]() { /* x by value, y by reference */ };
```

### Function Pointers and std::function

```cpp
#include <functional>

// Function pointer
int (*funcPtr)(int, int) = add;

// std::function object (more versatile)
std::function<int(int, int)> func = add;

// Can also store lambdas
std::function<int(int)> doubler = [](int x) { return x * 2; };
```

## Arrays and Strings

### Arrays

```cpp
// Declaration and initialization
int arr1[5];                       // Uninitialized array of 5 integers
int arr2[5] = {1, 2, 3, 4, 5};     // Initialized array
int arr3[] = {1, 2, 3, 4, 5};      // Size deduced from initializer
int arr4[5] = {1, 2};              // Partial initialization (rest are 0)

// Multidimensional arrays
int matrix[3][4];                  // 3×4 matrix (3 rows, 4 columns)
int cube[3][3][3];                 // 3D array

// Accessing elements
int first = arr2[0];               // First element (1-based indexing)
int last = arr2[4];                // Last element

// Common error: arrays don't track their size
int size = sizeof(arr2) / sizeof(arr2[0]);  // Calculate array size
```

### C-style Strings

```cpp
char str1[] = "Hello";            // Null-terminated character array
char str2[10] = "Hello";          // With explicit size
const char* str3 = "Hello";       // String literal (read-only)

// String operations (require <cstring>)
#include <cstring>
size_t len = strlen(str1);        // Length: 5
char concat[20];
strcpy(concat, str1);             // Copy str1 to concat
strcat(concat, " World");         // Append to concat
int comp = strcmp(str1, str2);    // Compare strings
```

### C++ Strings

```cpp
#include <string>

// Declaration and initialization
string s1;                        // Empty string
string s2 = "Hello";              // From string literal
string s3(5, 'a');                // String of 5 'a's: "aaaaa"
string s4 = s2;                   // Copy of s2

// Operations
int length = s2.length();         // or s2.size()
char first = s2[0];               // Access character (no bounds checking)
char safe = s2.at(0);             // Access with bounds checking
string concat = s2 + " World";    // String concatenation
s2 += " World";                   // Append to s2
string sub = s2.substr(0, 5);     // Substring (starting at 0, length 5)

// Searching
size_t pos = s2.find("llo");      // Find substring (returns position or string::npos)
bool contains = s2.find("llo") != string::npos;  // Check if contains substring

// Comparison
bool isEqual = (s2 == s3);        // String comparison
bool isLess = (s2 < s3);          // Lexicographical comparison

// Modification
s2.replace(0, 1, "J");            // Replace "H" with "J"
s2.erase(0, 1);                   // Remove first character
s2.insert(0, "H");                // Insert at position 0
s2.clear();                       // Empty the string
bool isEmpty = s2.empty();        // Check if empty
```

## STL Containers

### Vector

```cpp
#include <vector>

// Declaration and initialization
vector<int> v1;                          // Empty vector
vector<int> v2(5);                       // Vector of 5 zeros
vector<int> v3(5, 10);                   // Vector of five 10s
vector<int> v4 = {1, 2, 3, 4, 5};        // Using initializer list
vector<int> v5(v4);                      // Copy of v4
vector<int> v6(v4.begin(), v4.begin()+3); // First 3 elements of v4

// Size operations
int size = v4.size();                    // Number of elements
bool isEmpty = v4.empty();               // Check if empty
v4.resize(10);                           // Resize to 10 elements
v4.resize(12, 7);                        // Add 2 more elements with value 7
int capacity = v4.capacity();            // Current capacity
v4.reserve(20);                          // Reserve space for 20 elements
v4.shrink_to_fit();                      // Reduce capacity to match size

// Element access
int first = v4[0];                       // First element (no bounds checking)
int safe = v4.at(0);                     // With bounds checking
int front = v4.front();                  // First element
int back = v4.back();                    // Last element
int* data = v4.data();                   // Pointer to underlying array

// Modifiers
v4.push_back(6);                         // Add element to end
v4.pop_back();                           // Remove last element
v4.insert(v4.begin() + 2, 10);           // Insert 10 at position 2
v4.insert(v4.begin() + 2, 3, 10);        // Insert 3 copies of 10
v4.insert(v4.begin() + 2, {7, 8, 9});    // Insert multiple elements
v4.erase(v4.begin() + 2);                // Remove element at position 2
v4.erase(v4.begin(), v4.begin() + 3);    // Remove range of elements
v4.clear();                              // Remove all elements
vector<int>().swap(v4);                  // Clear and deallocate memory

// Iterating
for (auto it = v4.begin(); it != v4.end(); ++it) {
    cout << *it << " ";
}

// Range-based loop (C++11)
for (int x : v4) {
    cout << x << " ";
}

// Algorithm example (sort)
#include <algorithm>
sort(v4.begin(), v4.end());                   // Sort in ascending order
sort(v4.begin(), v4.end(), greater<int>());   // Sort in descending order

// 2D vector
vector<vector<int>> matrix(3, vector<int>(4, 0));  // 3×4 matrix of zeros
int val = matrix[1][2];                            // Access element
```

### Pair and Tuple

```cpp
#include <utility>    // For pair
#include <tuple>      // For tuple

// Pair
pair<int, string> p1 = {1, "one"};         // Create pair
pair<int, string> p2 = make_pair(2, "two"); // Alternative creation
int first = p1.first;                       // Access first element
string second = p1.second;                  // Access second element
bool isLess = (p1 < p2);                    // Lexicographical comparison

// Tuple
tuple<int, string, double> t1 = {1, "one", 1.1}; // Create tuple
tuple<int, string, double> t2 = make_tuple(2, "two", 2.2);
int tFirst = get<0>(t1);                    // Access elements by index
string tSecond = get<1>(t1);
double tThird = get<2>(t1);
```

### Set and Multiset

```cpp
#include <set>

// Set (sorted, no duplicates)
set<int> s1;                              // Empty set
set<int> s2 = {1, 2, 3, 4, 5};            // Using initializer list
set<int, greater<int>> s3;                // Custom comparison (descending)

// Size operations
int size = s2.size();                     // Number of elements
bool isEmpty = s2.empty();                // Check if empty

// Modifiers
s2.insert(6);                             // Insert element
auto result = s2.insert(6);               // Returns pair<iterator, bool>
bool wasInserted = result.second;         // Check if inserted
s2.erase(3);                              // Remove element by value
s2.erase(s2.begin());                     // Remove element by iterator
s2.erase(s2.begin(), s2.find(4));         // Remove range
s2.clear();                               // Remove all elements

// Lookup
auto it = s2.find(3);                     // Find element
bool contains = (it != s2.end());         // Check if found
int count = s2.count(3);                  // Count occurrences (0 or 1)
auto lower = s2.lower_bound(3);           // First element >= 3
auto upper = s2.upper_bound(3);           // First element > 3
auto range = s2.equal_range(3);           // Both bounds as pair

// Multiset (sorted, allows duplicates)
multiset<int> ms = {1, 2, 2, 3, 3, 3};    // Create multiset
ms.insert(3);                             // Insert another 3
int count3 = ms.count(3);                 // Count of 3s (now 4)
```

### Map and Multimap

```cpp
#include <map>

// Map (sorted key-value pairs, unique keys)
map<string, int> m1;                      // Empty map
map<string, int> m2 = {{"one", 1}, {"two", 2}}; // Using initializer list
map<string, int, greater<string>> m3;     // Custom key comparison

// Element access
int value = m2["one"];                    // Access by key (inserts if not found)
int valueOrDefault = m2.value_or("three", 0); // Value or default if not found

// Size operations
int size = m2.size();                     // Number of elements
bool isEmpty = m2.empty();                // Check if empty

// Modifiers
m2["three"] = 3;                          // Insert or update
m2.insert({"four", 4});                   // Insert only
m2.insert(make_pair("five", 5));          // Alternative insertion
auto result = m2.insert({"one", 10});     // Won't insert if key exists
bool wasInserted = result.second;         // Check if inserted
m2.erase("one");                          // Remove by key
m2.erase(m2.begin());                     // Remove by iterator
m2.erase(m2.begin(), m2.find("three"));   // Remove range
m2.clear();                               // Remove all elements

// Lookup
auto it = m2.find("one");                 // Find element
bool contains = (it != m2.end());         // Check if found
int count = m2.count("one");              // Count occurrences (0 or 1)
auto lower = m2.lower_bound("one");       // First key >= "one"
auto upper = m2.upper_bound("one");       // First key > "one"
auto range = m2.equal_range("one");       // Both bounds as pair

// Iterating
for (const auto& pair : m2) {
    cout << pair.first << ": " << pair.second << endl;
}

// Multimap (sorted key-value pairs, allows duplicate keys)
multimap<string, int> mm = {{"one", 1}, {"two", 2}, {"one", 10}};
int countOne = mm.count("one");           // Count of "one" keys (2)
```

### Unordered Containers

```cpp
#include <unordered_set>
#include <unordered_map>

// Unordered set (hash-based, no duplicates)
unordered_set<int> us = {1, 2, 3, 4, 5};
us.insert(6);                            // O(1) average insertion
bool contains = (us.find(3) != us.end()); // O(1) average lookup

// Unordered map (hash-based key-value pairs, unique keys)
unordered_map<string, int> um = {{"one", 1}, {"two", 2}};
um["three"] = 3;                         // O(1) average insertion
int value = um["one"];                   // O(1) average lookup

// Hash table properties
float loadFactor = us.load_factor();     // Current load factor
float maxLoadFactor = us.max_load_factor(); // Max load factor
us.max_load_factor(0.7f);                // Set max load factor
us.rehash(20);                           // Set minimum bucket count
us.reserve(15);                          // Reserve space for elements
```

### Stack

```cpp
#include <stack>

// Declaration and initialization
stack<int> st;                           // Empty stack

// Operations
st.push(1);                              // Add element to top
st.push(2);                              // Add another element
int top = st.top();                      // Access top element (2)
st.pop();                                // Remove top element
bool isEmpty = st.empty();               // Check if empty
int size = st.size();                    // Number of elements
```

### Queue

```cpp
#include <queue>

// Declaration and initialization
queue<int> q;                            // Empty queue

// Operations
q.push(1);                               // Add element to back
q.push(2);                               // Add another element
int front = q.front();                   // Access front element (1)
int back = q.back();                     // Access back element (2)
q.pop();                                 // Remove front element
bool isEmpty = q.empty();                // Check if empty
int size = q.size();                     // Number of elements
```

### Priority Queue

```cpp
#include <queue>

// Declaration and initialization (max heap by default)
priority_queue<int> pq;                          // Empty priority queue (max-heap)
priority_queue<int, vector<int>, greater<int>> minpq; // Min-heap

// Operations
pq.push(3);                              // Add element
pq.push(1);                              // Add element
pq.push(4);                              // Add element
int top = pq.top();                      // Access top element (largest: 4)
pq.pop();                                // Remove top element
bool isEmpty = pq.empty();               // Check if empty
int size = pq.size();                    // Number of elements

// Custom comparison
struct Compare {
    bool operator()(const pair<int, int>& a, const pair<int, int>& b) {
        return a.first > b.first;  // Min-heap based on first element
    }
};
priority_queue<pair<int, int>, vector<pair<int, int>>, Compare> customPQ;
```

### Deque

```cpp
#include <deque>

// Declaration and initialization
deque<int> dq;                           // Empty deque
deque<int> dq2 = {1, 2, 3, 4, 5};        // Using initializer list

// Operations (all operations at both ends are efficient)
dq.push_back(6);                         // Add to back
dq.push_front(0);                        // Add to front
dq.pop_back();                           // Remove from back
dq.pop_front();                          // Remove from front
int front = dq.front();                  // Access front element
int back = dq.back();                    // Access back element
int element = dq[2];                     // Random access
bool isEmpty = dq.empty();               // Check if empty
int size = dq.size();                    // Number of elements
```

## STL Algorithms

### Important Headers

```cpp
#include <algorithm>    // Most algorithms
#include <numeric>      // Numeric algorithms like accumulate
#include <functional>   // Function objects
```

### Non-modifying Sequence Operations

```cpp
// Find
auto it = find(v.begin(), v.end(), value);       // Find value
auto it = find_if(v.begin(), v.end(),            // Find using predicate
                  [](int x) { return x > 10; });
int count = count(v.begin(), v.end(), value);    // Count occurrences
int count = count_if(v.begin(), v.end(),         // Count using predicate
                     [](int x) { return x % 2 == 0; });

// Comparison
bool allEven = all_of(v.begin(), v.end(),        // Check if all meet condition
                     [](int x) { return x % 2 == 0; });
bool anyEven = any_of(v.begin(), v.end(),        // Check if any meets condition
                     [](int x) { return x % 2 == 0; });
bool noneEven = none_of(v.begin(), v.end(),      // Check if none meet condition
                       [](int x) { return x % 2 == 0; });

// Search
auto it = search(v1.begin(), v1.end(),           // Find subsequence
                v2.begin(), v2.end());

// Min/Max
auto minElement = min_element(v.begin(), v.end());      // Iterator to minimum
auto maxElement = max_element(v.begin(), v.end());      // Iterator to maximum
auto [minIt, maxIt] = minmax_element(v.begin(), v.end()); // Both at once
```

### Modifying Sequence Operations

```cpp
// Copy
copy(src.begin(), src.end(), dest.begin());        // Copy range to destination
copy_if(src.begin(), src.end(), dest.begin(),      // Copy with condition
        [](int x) { return x > 0; });
copy_n(src.begin(), 5, dest.begin());              // Copy first n elements

// Transform
transform(src.begin(), src.end(), dest.begin(),    // Apply function to each element
          [](int x) { return x * 2; });
transform(src1.begin(), src1.end(),                // Apply binary function
          src2.begin(), dest.begin(),
          [](int x, int y) { return x + y; });

// Generate and Fill
fill(v.begin(), v.end(), value);                   // Fill range with value
fill_n(v.begin(), 5, value);                       // Fill first n elements
generate(v.begin(), v.end(),                       // Generate values with function
         []() { return rand() % 100; });
iota(v.begin(), v.end(), 0);                       // Fill with increasing values

// Remove
auto newEnd = remove(v.begin(), v.end(), value);   // Remove value (doesn't resize)
v.erase(newEnd, v.end());                          // Actually erase removed elements
auto newEnd = remove_if(v.begin(), v.end(),        // Remove with condition
                      [](int x) { return x < 0; });

// Replace
replace(v.begin(), v.end(), oldValue, newValue);   // Replace value
replace_if(v.begin(), v.end(),                     // Replace with condition
           [](int x) { return x < 0; }, 0);

// Reverse and Rotate
reverse(v.begin(), v.end());                       // Reverse range
rotate(v.begin(), v.begin() + 3, v.end());         // Rotate elements
```

### Sorting and Related Operations

```cpp
// Sorting
sort(v.begin(), v.end());                          // Sort in ascending order
sort(v.begin(), v.end(), greater<int>());          // Sort in descending order
sort(v.begin(), v.end(),                           // Sort with custom comparator
     [](int a, int b) { return abs(a) < abs(b); });
partial_sort(v.begin(), v.begin() + 5, v.end());   // Sort just first 5 elements
stable_sort(v.begin(), v.end());                   // Stable sort

// Binary search (on sorted ranges)
bool found = binary_search(v.begin(), v.end(), value);  // Check if exists
auto it = lower_bound(v.begin(), v.end(), value);  // First element >= value
auto it = upper_bound(v.begin(), v.end(), value);  // First element > value
auto [first, last] = equal_range(v.begin(), v.end(), value); // Both bounds

// Partitioning
auto it = partition(v.begin(), v.end(),            // Partition by condition
                   [](int x) { return x % 2 == 0; });
bool isPartitioned = is_partitioned(v.begin(), v.end(),  // Check if partitioned
                                  [](int x) { return x % 2 == 0; });

// Nth element
nth_element(v.begin(), v.begin() + n, v.end());    // Nth element in sorted position
```

### Numeric Operations

```cpp
#include <numeric>

// Basic operations
int sum = accumulate(v.begin(), v.end(), 0);         // Sum of elements
int product = accumulate(v.begin(), v.end(), 1,      // Product of elements
                        multiplies<int>());
int sum = reduce(v.begin(), v.end());                // C++17 parallel-friendly sum

// Adjacent element operations
vector<int> differences(v.size() - 1);
adjacent_difference(v.begin(), v.end(),              // Differences of adjacent elements
                   differences.begin());
vector<int> sums(v.size() - 1);
adjacent_find(v.begin(), v.end(),                    // Find equal adjacent elements
             sums.begin());

// Prefix sums
vector<int> prefixSums(v.size());
partial_sum(v.begin(), v.end(), prefixSums.begin()); // Cumulative sum

// Inner product
int dotProduct = inner_product(v1.begin(), v1.end(), // Dot product
                              v2.begin(), 0);
```

### Heap Operations

```cpp
// Create heap
make_heap(v.begin(), v.end());                      // Create max-heap
make_heap(v.begin(), v.end(), greater<int>());      // Create min-heap

// Heap operations
v.push_back(value);                                 // Add element to end
push_heap(v.begin(), v.end());                      // Fix heap after push_back
pop_heap(v.begin(), v.end());                       // Move largest to end
v.pop_back();                                       // Remove element now at end

// Heap properties
bool isHeap = is_heap(v.begin(), v.end());          // Check if is a heap
auto it = is_heap_until(v.begin(), v.end());        // Iterator to first non-heap element
```

### Set Operations (on sorted ranges)

```cpp
// Difference, union, intersection
set_difference(v1.begin(), v1.end(),                // Elements in v1 but not in v2
               v2.begin(), v2.end(),
               result.begin());
set_union(v1.begin(), v1.end(),                     // Elements in either v1 or v2
          v2.begin(), v2.end(),
          result.begin());
set_intersection(v1.begin(), v1.end(),              // Elements in both v1 and v2
                v2.begin(), v2.end(),
                result.begin());
set_symmetric_difference(v1.begin(), v1.end(),      // Elements in either but not both
                        v2.begin(), v2.end(),
                        result.begin());

// Set membership
bool isSubset = includes(v1.begin(), v1.end(),      // Check if v2 is subset of v1
                        v2.begin(), v2.end());
```

## Common Algorithm Patterns

### Binary Search Implementation

```cpp
// Binary search on sorted array
bool binarySearch(const vector<int>& arr, int target) {
    int left = 0;
    int right = arr.size() - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;  // Avoid overflow
        
        if (arr[mid] == target)
            return true;
        else if (arr[mid] < target)
            left = mid + 1;
        else
            right = mid - 1;
    }
    
    return false;
}

// Find first position greater than or equal to target
int lowerBound(const vector<int>& arr, int target) {
    int left = 0;
    int right = arr.size();
    
    while (left < right) {
        int mid = left + (right - left) / 2;
        
        if (arr[mid] < target)
            left = mid + 1;
        else
            right = mid;
    }
    
    return left;
}

// Find first position greater than target
int upperBound(const vector<int>& arr, int target) {
    int left = 0;
    int right = arr.size();
    
    while (left < right) {
        int mid = left + (right - left) / 2;
        
        if (arr[mid] <= target)
            left = mid + 1;
        else
            right = mid;
    }
    
    return left;
}
```

### Two Pointers Technique

```cpp
// Find pair with given sum in sorted array
bool findPair(const vector<int>& arr, int target) {
    int left = 0;
    int right = arr.size() - 1;
    
    while (left < right) {
        int currentSum = arr[left] + arr[right];
        
        if (currentSum == target)
            return true;
        else if (currentSum < target)
            left++;
        else
            right--;
    }
    
    return false;
}

// Remove duplicates from sorted array in-place
int removeDuplicates(vector<int>& nums) {
    if (nums.empty()) return 0;
    
    int writeIndex = 1;
    for (int readIndex = 1; readIndex < nums.size(); readIndex++) {
        if (nums[readIndex] != nums[readIndex - 1]) {
            nums[writeIndex++] = nums[readIndex];
        }
    }
    
    return writeIndex;
}

// Find maximum water container (container with most water problem)
int maxArea(const vector<int>& height) {
    int left = 0;
    int right = height.size() - 1;
    int maxWater = 0;
    
    while (left < right) {
        int h = min(height[left], height[right]);
        int w = right - left;
        maxWater = max(maxWater, h * w);
        
        if (height[left] < height[right])
            left++;
        else
            right--;
    }
    
    return maxWater;
}

// Three-sum problem
vector<vector<int>> threeSum(vector<int>& nums) {
    vector<vector<int>> result;
    if (nums.size() < 3) return result;
    
    sort(nums.begin(), nums.end());
    
    for (int i = 0; i < nums.size() - 2; i++) {
        // Skip duplicates
        if (i > 0 && nums[i] == nums[i-1]) continue;
        
        int left = i + 1;
        int right = nums.size() - 1;
        int target = -nums[i];
        
        while (left < right) {
            int sum = nums[left] + nums[right];
            
            if (sum == target) {
                result.push_back({nums[i], nums[left], nums[right]});
                
                // Skip duplicates
                while (left < right && nums[left] == nums[left+1]) left++;
                while (left < right && nums[right] == nums[right-1]) right--;
                
                left++;
                right--;
            } else if (sum < target) {
                left++;
            } else {
                right--;
            }
        }
    }
    
    return result;
}
```
