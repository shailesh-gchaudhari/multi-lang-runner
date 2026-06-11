Stats Program - Finds max, min, and average of a list of 10 numbers.
"""

numbers = [42, 17, 85, 3, 96, 54, 28, 71, 9, 63]

highest = max(numbers)
lowest  = min(numbers)
average = sum(numbers) / len(numbers)

print("=" * 40)
print("        PYTHON STATS PROGRAM")
print("=" * 40)
print(f"Numbers  : {numbers}")
print(f"Highest  : {highest}")
print(f"Lowest   : {lowest}")
print(f"Average  : {average:.2f}")
print("=" * 40)
