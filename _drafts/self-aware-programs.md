---
layout: post
title: Self Aware Programs
categories:
- recursion-theorem
---

# A Classical Exercise

A computer program which produces its own source code is called a quine, named after the logician Willard Van Orman Quine.

**Exercise:** Write a quine in your favourite programming language.

If you haven't solved this exercise before, I urge you to stop right now and give it a try.

To give you an idea of why this is an interesting problem, let us try to solve it in a naive way. Instead of using an actual programming language
I will use pseudocode to keep things simple.

The obvious candidate of a quine is

```
Print your own source code
```

This looks like cheating but actually there are languages which allow this. For instance

```
10 List
```

is a valid GWBasic program which, when run, prints `10 List` on the screen. Actually, in GWBasic, *any* code which starts with `10 List`
is a quine.

So to make things less trivial and more generic, let us restrict ourselves to text manipulations. In this case, the first candidate is
```
Print "Print"
```

The output of this code is simply `Print`. So it doesn't work. Seeing this, you may try
```
Print "Print "Print""
```

This time the output is `Print "Print"`. Failed again. Actaully, any code of the form `Print "<any kind of fixed text>"` will fail
as the source code is strictly longer than the text it prints. Now here is an idea to circumvent this: We can use the the given text, or its parts, more than once!
So let us try a program like this:
```
Let A be the following text:
"<there is going to be a text here>"
<there are going to be commands here explaining what to do with A>
```

As we will construct the source code using the parts of the text A, the first line of the code should be a part of A. So our program should look like this:
```
Let A be the following text:
"Let A be the following text:
<there are going to be more lines here>"
<there are going to be commands here explaining what to do with A>
```

Of course, we will print the first line. Thus we should have a program like this:
```
Let A be the following text:
"Let A be the following text:
<there are going to be more lines here>"
Print the first line of A
<there are going to be more commands here>
```

Obviously the command `Print the first line of A` should appear somewhere in A. So let's add it to A to obtain

```
Let A be the following text:
"Let A be the following text:
Print the first line of A
<there are going to be more lines here>"
Print the first line of A
<there are going to be more commands here>
```

Now the second printing command should print what comes after the first line. But this is simply the text A in quotation. Therefore we should have

```
Let A be the following text:
"Let A be the following text:
Print the first line of A
<there are going to be more lines here>"
Print the first line of A
Print A in quotation
<there are going to be more commands here>
```

Again these commands should appear in A. So we have

```
Let A be the following text:
"Let A be the following text:
Print the first line of A
Print A in quotaion
<there are going to be more lines here>"
Print the first line of A
Print A in quotation
<there are going to be more commands here>
```

Note that, up untill now, all the steps we took were pretty much forced. The final step will be a little different and require a tid bit of creativity.
Here is our finished quine:

```
Let A be the following text:
"Let A be the following text:
Print the first line of A
Print A in quotaion
Print A except for its first line
Print the first line of A
Print A in quotation
Print A except for its first line
```

As an exercise, you may translate this quine into a real programming language. Evene though the quine has the essential idea, you may still need to deal with a few details such as escaping quotation marks.

Now this was fun, bu also ad-hoc. Can write quines in *all* programming languages? The answer is yes for all Turing complete languages and this follows from one of the most fundamental results in recursion theory, the Kleene's recursion theorem.

# Kleene's Recursion Theorem

# Unsolvable Problems
