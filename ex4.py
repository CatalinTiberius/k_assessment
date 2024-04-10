with open('ex3_text.txt', 'r') as f:
    for line in f.readlines():
        if 'Critical' in line:
            columns = line.split()
            first_column = columns[0]
            last_column = columns[-1]
            print(first_column, last_column)
