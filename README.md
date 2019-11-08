# Python3 Onelinerizer

Convert Python 3 code into one line, inspired by the [Python 2 counterpart](http://www.onelinerizer.com/)

**This project is currently not completed!**

## Motivation

Modern software enginerring has been long emphasizing the [composablilty](https://en.wikipedia.org/wiki/Composability) of programs. As a modern programming language, Python is the ideal way to achieve the goal. But how to prove that?

## Supported Statements

**Import**

Before:

```python
import sys, pandas as pd
sys.stderr.write(repr(pd.read_csv('test.txt')))
```

After:

```python
(lambda sys, pd: (sys.stderr.write(repr(pd.read_csv('test.txt')))))(__import__("sys"), __import__("pandas"))
```

**Assign**

Before:

```python
a, b = 1, 2
print(a + b)
```

After:

```python
next((print(a + b) for a, b in ((1, 2),)),)
```

**Function Definition**

Before:

```python
def foo(arg1, arg2, *args, **kwargs):
    print(arg1, arg2, args, kwargs)
foo(1, 2, 3, 4, bar=5, baz=6)
```

After:

```python
next((foo(1, 2, 3, 4, bar=5, baz=6) for foo in ((lambda arg1, arg2, *args, **kwargs: print(arg1, arg2, args, kwargs)),)),)
```
