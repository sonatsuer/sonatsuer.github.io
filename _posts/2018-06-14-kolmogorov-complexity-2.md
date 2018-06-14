---
layout: post
title: Kolmogorov Complexity (Part 2 of 2)
categories:
- kolmogorov-complexity
---

# A Crash Course in Logic

In this post we wil apply th Kolmogorov complexity to logic. To be more precise, we will answer to classical questions about foundations
of mathematics. But first, let's clarify what we mean by foundations.

For simplicity and definiteness we will stick with set theory (with first order logic) as our foundational theory.
The idea is to express *every* notion we use in mathematics in terms of sets using a formal language. Our formal language will have only two
primitive notions, namely equality, which we will denote by \\(=\\) and membership, which we will denote by \\(\in\\). Both equality and
memebership will be binary relations on sets.

Other than these two, we will have the following symbols in our language:
\\[
  \forall,\, \exists,\, \wedge,\, \vee,\, \neg,\, \rightarrow,\, \leftrightarrow,\, (,\, ),\, x,\, '.
\\]

The last symbol, namely \\('\\) is used to obtain an unbounded number of variables from the single variable symbol \\(x\\)
as follows:
\\[
  x',\, x''\, x'''\, x''''\, x'''''\, x''''''\, \ldots
\\]
However, for ease of reading, we will use lower case Roman letters such as \\(x,y,z,t,\ldots\\) instead of \\(x',\, x''\, x''',\ldots\\) The point
here is that even though our alphabet has finitely many symbols, we can talk about infinitely many variables.

When we talk about sets, we will use only *meaningful* or well formed strings in these symbols. I will not define what exactly well formed means but
you can assume that a well formed formula is a string in our symbols which can be parsed according to some grammar. Intuitively, strings like
\\[
  \forall )( \rightarrow xx \;\;\text{ or }\;\; ''\vee x \wedge
\\]
are not well formed but
\\[
  \forall x \forall y (( \forall t (t\in x)\leftrightarrow (t\in y)) \leftrightarrow x = y)
\\]
is well formed. Actually this second formula says that two sets are equal if and only if they have the same elements. Note that menaingful
does not mean true. For instance
\\[
  \exists x\forall y (y\in x)
\\]
is meaningfull and says that there is set which contains all sets. However, it is not true in most set theories.

One important property of well formed formulas is that there is an algorithm which can decide whether an arbitrary string is well formed
or not.

We want to be able to prove statements about mathematical using our language. After all, this is supposed to be a foundational theory. Since
we have statements, namely the well formed formulas, only two pieces are missing now: assumptions (or axioms) and a notion of proof.

Again for definiteness, we will work with the axioms of ZFC (Zermalo-Frenkel-Choice) set theory. The actual axioms are not important but you can look
them up if you are curious. The important fact about the axioms is the following: There is an algorithm which can decide whether an arbitrary string
is an axiom.

Finally a proof of a well formed formula \\(varphi\\) is simply a sequence of well formed formulas \\(\varphi_1,\varphi_2,\ldots,\varphi_n\\) such that
\\(\varphi_n = \varphi\\) and each \\(\varphi_i\\) is either an axiom or it is obtained from earlier elements in the sequence using deduction rules.
Deduction rules here are rules like "from \\(\varphi\rightarrow\psi\\) and \\(\varphi\\) deduce \\(\psi\\)". You guessed it, the actual rules are not
importatnt but the important fact about proofs is that there is algorithm which can decide whether an arbitrary sequence of strings is a proof or not.

A theorem of ZFC is a well formed formula which has a proof. Now you might think that there is an algorithm which can decide whether an arbitrary string is a theorem of ZFC. However, as we will see soon, this is not true. The best you can do is to *enumerate* all theorems of ZFC. In other words
there is an algorithm which generates an infinite list containing *all* theorems of ZFC. You can probably guess the algorithm: Generate all finite
sequences of well formed formulas in, say, lexicographic ordering. If the sequence happens to be a proof, add the proven formula to the list.

If you have not heard of recursively enumerable sets before, you might want to think about why this is weaker than having an alogorithm which can
decide whether an arbitrary string is a theorem.

# Chaitin's Incompleteness Theorem
At this point, you might ask the following question: We have only talked about sets so far but we were looking for a foundational theory
for all of mathemtaics. Is this really enough? The answer is yes. This may look strange because it seems that there objects in mathematics which are
clearly not sets. For instance \\(\pi\\) is not a set, it is a number. The trick is that \\(pi\\), and all mathematical objects for that matter, can
be *encoded* as sets.

Here are a few examples to give you an idea. We can define
\\[
  0 = \emptyset,\; 1 = \\{0\\},\; 2 = \\{0,1\\},\; 3 = \\{0,1,2\\},\ldots
\\]
So a natural number is the set of smaller natural numbers. For two sets \\(x\\) and \\(y\\) we can define
\\[
  (x,y) = \\{ \\{x\\}, \\{x,y\\}\\}
\\]
and prove that this actually works like an ordered pair (Exercise: Do it!). Once you have ordered pairs, you can have Cartesian products, relations and
functions etc.

From now on I will assume that we agreed on encodings of all the notions in mathematics as sets. Note that notions like well formed formula, proof and
algorithm are also encoded in this way. So ZFC is capable of talking about Kolmogorov complexity, or even itself.

Here comes the big theorem of this post. Recall that \\(K\\) denotes the Kolmogorov complexity.

>*There is a constant \\(L\\) such that for no \\(\sigma\\), the statement \\(K(\sigma) > L\\) is a theorem of ZFC.*

Suppose not. Then for any natural number \\(n\\) there is a \\(\sigma_n\\) such that \\(K(\sigma_n)\\ > n\\) is a theorem of ZFC. This implies that
there is a computable function \\(f\\) such that for each natural number \\(n\\) the inequality \\(K(f(n)) > n\\) is a theorem of ZFC. Indeed,
given any \\(n\\), using the fact that theorems of ZFC are enumerable, search for a theorem of the form \\(K(\sigma) > n\\). By assumption this
search will end even though the list is infinite. Define \\(f(n)\\) to be the first such \\(\sigma\\) you find. But this is the first step in
the argument which we proves the incomputability of \\(K\\) in the previous post! You can simply copy the rest of the proof here.

Let us stop here and look at what we have proved. In ZFC, there is an upper bound on the *provable* Kolmogorov complexity. However, there is
no upper bound on Kolmogorov complexity! Therefore there are some true statemets of the form \\(K(\sigma) > k\\) which are not theorems of ZFC.
This means that ZFC is incomplete, in the sense that it cannot capture all true statemets. This is Chaitin's version of Gödel's first incompleteness
theorem.

# Gödel's Second Incompleteness Theorem
We have been making an implicit assumtion about our foundational theory, namely that it was consistent. In other words, we assumed that no
contradiction is a theorem of ZFC. A contraiction is a vacuously false statment like \\(\exists x (\neg x = x)\\), by the way. This is equivalent to
assuming that not all well formed formulas are theorems of ZFC as everything can be deduced from a contradiction. Oviously, this is a must have
for a foundational theory.

Recall that ZFC can prove statements about itself. So wouldn't it be nice to actaully have a proof of this assumption in ZFC? This would be proving the consistency of our foundational theory within the theory itself, showing that the theory is self sufficient. Certainly Hilbert wanted to do it.
However his efforts were crashed by, Gödel who proved that no sufficiently rich theory can prove its own consistency. Here sufficiently rich roughly
means strong enough to interpret arithmetic. Now we will give a modern proof of this theorem using Kolmogorov complexity. The proof is due to Shira
Kritchman and Ran Raz.

Their proof is loosely based on the surprise examination paradox:

> In your introduction to logic class, you announce that the students will have an exam next week, but they will not
> know the exact day of the exam. So the exam cannot be on Friday because otherwise, the students will know that the exam
> will be on Friday after not having an exam on Thursday. Similarly the exam cannot be on Thursday, Wednesday, Tuesday
> or Monday.

Let \\(L\\) be as in Chaitin's theorem. Let \\(\ell = c^{L + 1}\\) where \\(c\geq 2\\) is the number of symbols we use in our fixed
programming language. Define
\\[
  \mathcal{K} = \\{\sigma\, \colon K(\sigma) > L,\, \ell(\sigma) \leq \ell \\}
  \;\;\text{ and }\;\;
  k = |\mathcal{K}|
\\]
The number \\(k\\) will roughly correspond to the day on which the exam will take place counted from the end of the week. Clearly \\(k\geq 1\\) as
there are less than \\(\ell\\) many programs of size \\(L\\). Moreover, this observation is also a theorem of ZFC as it is simple counting.

Now let us prove that \\(k \geq 2\\). Suppose not. Then \\(k=1\\). Let \\(\sigma_0\\) be the unique element of \\(\mathcal{K}\\). Using the fact that the theorems of ZFC are enumerable, look for proofs of statements of the form \\(K(\sigma) \leq L\\) for \\(\ell(\sigma) \leq \ell\\). By assumption, for all \\(\sigma\not=\sigma_0\\) we have such a proof. So when we have \\(\ell - 1\\) proofs, the remaining string should be \\(\sigma_0\\) which has
to have complexity greater than \\(L\\). But we just proved, in ZFC, that a certain string has complexity greater than \\(L\\). This contradicts the choice of \\(L\\).

Now let us prove that \\(k \geq 3\\). Suppose not. Then \\(k = 2\\). Let \\(\sigma_0, \sigma_1\\) be the only elements of \\(\mathcal{K}\\). Using the
fact that the theorems of ZFC are enumerable, look for proofs of statements of the form \\(K(\sigma) \leq L\\) for \\(\ell(\sigma) \leq \ell\\). By assumption, for all \\(\sigma\not=\sigma_0, \sigma_1\\) we have such a proof. So when we have \\(\ell - 2\\) proofs, the remaining two strings should
be \\(\sigma_0\\) and \\(\sigma_1 \\) which have to have complexity greater than \\(L\\). But we just proved, in ZFC, that a certain string has complexity greater than \\(L\\). This contradicts the choice of \\(L\\).

Now let us prove that \\(m \geq 4\\)\ldots Well, you see the pattern. Using this method we can exhaust all possible values for \\(k\\) and obtain a
contradiction. So assuming that ZFC can prove its consistency leads to a contrdiction.