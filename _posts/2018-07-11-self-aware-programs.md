---
layout: post
title: Self Aware Programs
categories:
- recursion-theorem
---

# A Classical Exercise

A computer program which produces its own source code is called a quine, named after the logician Willard Van Orman Quine.

**Exercise:** Write a quine in your favorite programming language.

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

So, to make things less trivial and more generic, let us restrict ourselves to text manipulations. In this case, the first candidate is
```
Print "Print"
```

The output of this code is simply `Print`. So it doesn't work. Seeing this, you may try
```
Print "Print "Print""
```

This time the output is `Print "Print"`. Failed again. Actually, any code of the form `Print "<any kind of fixed text>"` will fail
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
Print A in quotation
<there are going to be more lines here>"
Print the first line of A
Print A in quotation
<there are going to be more commands here>
```

Note that, up until now, all the steps we took were pretty much forced. The final step will be a little different and require a tid bit of creativity.
Here is our finished quine:

```
Let A be the following text:
"Let A be the following text:
Print the first line of A
Print A in quotation
Print A except for its first line"
Print the first line of A
Print A in quotation
Print A except for its first line
```

As an exercise, you may translate this quine into a real programming language. Even though the quine above has the essential idea, you may still need to deal with a few language specific details such as escaping quotation marks. Here is one for you in Haskell meant to be evaluated in repl.

```
let x = ["let x = ", " in putStr (x !! 0) >> putStr (show x) >> putStr (x !! 1)"] in putStr (x !! 0) >> putStr (show x) >> putStr (x !! 1)
```

Now this was fun, bu also ad-hoc. The natural question to ask here whether there is a principled way of writing, not only quines, but programs which have some kind of access to their own source code. The answer is yes and this follows from one of the most fundamental results in recursion theory, the recursion theorem.

# Kleene's Recursion Theorem

I want to work with a Turing complete programming language. Luckily, what we need is essentially what I described in the first section of
[Kolmogorov Complexity (1/2)](https://sonatsuer.github.io/kolmogorov-complexity/2018/05/21/kolmogorov-complexity-1.html). The differences
are that we do not need \\(\mathcal{L}\\) to contain UTF-8 characters and we do not need an assumption on the way we represent natural numbers.

Let \\(\mathcal{M}\\) be the set of all strings from \\(\mathcal{L}\\) and let \\(\mathcal{C}(n)\\) be the set of all source codes
expecting \\(n\\) inputs, where \\(n\\) is a natural number. Then, for each \\(c\in\mathcal{C}(n)\\), we have a partial function \\(f_c\\) from
\\(\mathcal{M}^n\\) to \\(\mathcal{M}\\), which is simply the partial function computed by the source code \\(c\\). These functions are called the computable partial functions.

Let us start with a simple but useful lemma.

**Lemma:** There is a computable function \\(s\\) such that for any \\(x\in\mathcal{M}\\) and \\(c\in\mathcal{C}(2)\\) we have
\\(s(c,x)\in\mathcal{C}(1)\\) and
\\[
   f_c(x,y) = f_{s(c,x)}(y).
\\]

**Proof:** Let \\(x\in\mathcal{M}\\) and \\(c\in\mathcal{C}(2)\\) be given. As \\(c\in\mathcal{C}(2)\\), \\(c\\) should look like this:
```
Ask for a value from the user and store it as A
Ask for a value from the user and store it as B
<Some commands>
```
All \\(s\\) will need to do is to convert this code into the following one:
```
Let A be x
Ask for a value from the user and store it as B
<Some commands>
```
In other words, it should hard-code the value \\(x\\). It is not difficult to imagine an algorithm doing this. Thus, by appealing to the Church-Turing hypothesis, we are done. \\(\square\\)

Now we can prove the recursion theorem.

**Theorem (Kleene):** Let \\(f(x,y)\\) be a partial two-variable computable function. Then there is a \\(c\in\mathcal{C}(1)\\) such that
\\[
  f(c,y) = f_c(y)
\\]
holds for all \\(y\\).

**Proof:** Let \\(a\in\mathcal{C}(2)\\) be such that \\(f = f_a\\). Such an \\(a\\) exists because this is what computable means. Now,
by the lemma, we already have something close, namely
\\[
  f(x,y) = f_a(x,y) = f_{s(a,x)}(y).
\\]
So, if we could find a solution for \\(x = s(a,x)\\), then we would be done. However, in this equation, we have some control over \\(x\\) but
the other parameter \\(a\\) is very heavily constrained since \\(f = f_a\\).

Now comes the brilliant idea: instead of working with \\(x\\)
let us work with a computable function of \\(x\\). Consider \\(f(g(x),y)\\) for a not yet determined computable function. As both \\(f\\)
and \\(g\\) are computable, so is this new function. Therefore there is a \\(b\in\mathcal{C}(2)\\) such that \\(f_b(x,y) = f(g(x),y)\\). Now we have
\\[
  f(g(x),y) = f_b(x,y) = f_{s(b,x)}(y)
\\] so the equation we need to solve in this case is
\\[
  g(x) = s(b, x)
\\]
instead of \\(x = s(a,x)\\). Introducing \\(g\\) into the problem gave us some room because now we can choose both \\(x\\) *and* \\(g\\). Squinting
at the equation for a few seconds, we see that there is a trivial solution, namely \\(g(x) = s(x,x)\\) and \\(x = b\\)! We were lucky! (Just kidding,
I planned all of this.)

Let us summarize this "stream of consciousness" into a more traditional proof. Let \\(b\in\mathcal{C}(2)\\) be such that \\(f_b(x,y) = f(s(x,x),y)\\)
and let \\(c = s(b,b)\\). Then
\begin{align}
f(c,y) & = f (s (b,b), y) \newline
       & = f_b (b, y) \newline
       & = f_{s(b,b)}(y) \newline
       & = f_c(y)
\end{align}
This finishes the proof. \\(\square\\)

Let us look at example to appreciate the power of this theorem.

**Example:** There is a \\(c\in\mathcal{C}(1)\\) such \\(f_c(y) = c\\) for all \\(y\\). Note that \\(c\\) is just a quine.
Let \\(f(x,y) = x\\). Obviously \\(f\\) is computable. Thus, by the recursion theorem, there is a \\(c\\) such that
\\[
  f_c(y) = f(c, y) = c
\\]
for all \\(y\\).

Here is another one.

**Example:** There is a \\(c\in\mathcal{C}(1)\\) such
\\[
  f_c(y) =
  \begin{cases}
   \text{reversed } c, \text{ if $c$ is longer than $y$} \newline
   \text{collected works of Shakespeare}, \text{ otherwise}
  \end{cases}
\\]
Let
\\[
  f(x,y) =
  \begin{cases}
   \text{reversed } x, \text{ if $x$ is longer than $y$} \newline
   \text{collected works of Shakespeare}, \text{ otherwise}
  \end{cases}
\\]
and apply the recursion theorem.

The pattern here is clear: If you want to find a code in \\(\mathcal{C}(1)\\) which accesses its own source code, just write a code in
\\(\mathcal{C}(2)\\) which asks for its own source code as input from the user. The recursion theorem takes care of the rest. From now on, I will freely use a subroutine `access your own code` and assume that you can implement it using the recursion theorem.

# Unsolvable Problems

Now we know how to fake an access-your-own-code subroutine. You might think that we can write amazing programs by using it but from a practical point of view such a subroutine is pretty useless. So what can we do with it? Well, mathematical logic of course! (See the last paragraph of [Kolmogorov Complexity (1/2)](https://sonatsuer.github.io/kolmogorov-complexity/2018/05/21/kolmogorov-complexity-1.html))

As a warmup exercise, let us prove the unsolvability of the halting problem using the recursion theorem. Of course there is a much simpler proof via diagonalization but, as I said, this is a warmup exercise. Suppose that the halting problem *is* solvable. This means that the function defined by
\\[
  f(c, x) =
  \begin{cases}
  \text{yes, }\, \text{if $c$ is in $\mathcal{C}(1)$ and $f_c(x)$ is defined} \newline
  \text{no, }\, \text{otherwise}
  \end{cases}
\\]
is computable. Now consider the following algorithm:
```
Ask for a value from the user and store it as X
Access your own code and call it S
if f(S, X) = no
  print "I am not supposed to halt!"
  Halt
if f(S, X) = yes
  print "I am supposed to halt!"
  loop forever
```

This program looks at its code, and sees ---using the function \\(f\\)--- whether it will halt, and then does exactly the opposite. So it halts if and only if it does not halt! Contradiction.

Before proving another impossibility result, let we will prove a fixed point version the recursion theorem, sometimes called the second recursion theorem.

**Theorem:** Let \\(g\\) be a total computable function with a single variable such that \\(g(c)\in\mathcal{C}(1)\\) for all \\(c\in\mathcal{C}(1)\\). Then there is a \\(S\in\mathcal{C}(1)\\) such that \\(f_S = f_{g(S)}\\).

Such an \\(S\\) is called a fixed point of \\(g\\).

**Proof:** Consider the following code:
```
Ask for a value from the user and store it as X
Access your own code and call it S
Simulate g(S) running on input X
```
Let us call this code `S`, just like the program itself does. Now for any given `X`, if we run `S` on input `X`, we get what `g(S)` does on input `X`. But this simply means that on any
`X`, the codes `S` and `g(S)` have the same behavior. So we are done. \\(\square\\)

Now we can prove a classical result due to Henry Gordon Rice.

**Theorem:** Let \\(\mathcal{A}\\) be a decidable subset of \\(\mathcal{C}(1)\\) such that \\(\mathcal{A}\not= \emptyset, \mathcal{C}(1)\\). Then there are \\(a,b\in\mathcal{C}(1)\\) such that \\(a\in \mathcal{A}\\), \\(b\in \mathcal{C}(1)\setminus\mathcal{A}\\) and \\(f_a = f_b\\).

**Proof:** Fix \\(a'\in \mathcal{A}\\), \\(b'\in \mathcal{C}(1)\setminus\mathcal{A}\\). Define
\\[
  g(c) =
  \begin{cases}
  a'\text{ if } c\in\mathcal{A} \newline
  b'\text{ if } c\not\in\mathcal{A}
  \end{cases}
\\]
As \\(\mathcal{A}\\) is decidable, \\(g\\) is computable. Let \\(c\\) be a fixed point of \\(g\\). Then \\(f_c = f_{g(c)}\\). Moreover, by construction, \\(c\\) and \\(g(c)\\) cannot be both in \\(\mathcal{A}\\). This finishes the proof. \\(\square\\)

This is a remarkable theorem, because it says that there is no decidable semantic property! For instance the following sets are all undecidable:
\\[
  \begin{align}
  & \\{c\in\mathcal{C}(1) | \text{domain of $f_c$ has 73 elements} \\}, \newline
  & \\{c\in\mathcal{C}(1) | \text{$f_c$ is total} \\}, \newline
  & \\{c\in\mathcal{C}(1) | \text{$f_c$ turns an even-length string to an odd-length string} \\}, \newline
  & \\{c\in\mathcal{C}(1) | \text{$f_c$ is constant} \\}, \newline
  & \\{c\in\mathcal{C}(1) | \text{$f_c(x)$ has the characters a and 7 for all $x$} \\}, \newline
  & \\{c\in\mathcal{C}(1) | \text{$f_c(x)$ is longer than $x$ for all $x$} \\}, \newline
  & \ldots
  \end{align}
\\]

For our final example, we need a definition. Call an element \\(c\in\mathcal{C}(1)\\) minimal if for any shorter \\(c'\in\mathcal{C}(1)\\) we have \\(f_c \not= f_{c'}\\). It is not difficult to prove that minimality is not a decidable property. I will leave the details to you.

*Hint:* Again, suppose that minimality *is* decidable and consider the following code:
```
Ask for a value from the user and store it as X
Access your own code and call it S
Construct a minimal M longer than S and call it W
Simulate W running on input X
```
