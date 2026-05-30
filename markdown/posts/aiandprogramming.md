---
title: A Motto for AI-Assisted Programming
---

## TL;DR

I have been using AI (specifically Claude Code) at work and in my personal projects. And guess what? I have opinions now! In this post I want to isolate a principle that served me well during AI-assisted programming. The principle itself is not something particularly deep or original. However, I think that thinking and talking about general principles as opposed to specifics has some value.

## Why do we even produce code?

Can't we just use an agentic assistant as the application? When a request comes to our server, we can simply give it to our agentic assistant wrapped in a prompt saying something like this:

> _Look at the API.md file and extract the intent of the user, then use BusinessLogic.md to determine what to do. If necessary access the DB using DBSchemata.md file and prepare a response._

This is obviously a bad idea but let's explicitly list some of the down sides. It is slow, expensive and unreliable. Also it makes your operation dependent on yet another external provider. Moreover, it is not clear how to debug prompts, let alone decide if a problem is an actual bug as opposed to AI being unpredictable. Actually, these points make sense at any scale and anyone using agentic assistants is aware of them. But... Yes, there is a but and it is the raison d'être of this post. Let me explain.

Recently I came across a Claude skill that fixes a technical problem. The problem it solves is irrelevant. It was just invoking bash commands and using command line tools. So  it was possible to just make it a script. Yet it was packaged as a skill which does not even work offline. I don't really blame the person who did it. After all, "The Complete Guide to Building Skills for Claude" doesn't even remotely entertain the idea that not everything has to be a skill. Similarly, there is a skill generator but there is no official skill-to-script translator or a skill optimizer.

Of course Claude is not trying to do everything purely using existing tools. For instance if you ask it to solve a variant of [the eight queens problem](https://en.wikipedia.org/wiki/Eight_queens_puzzle) it tries to write a python script to generate a solution --at least it did when I tried it.

## Generating Tools

This behavior of Claude is a move in the right direction but I think, overall, it is not enough. Because it is triggered when Claude has no other choice. Therefore it is often the developer's responsibility to generate the intermediate tooling. To summarize as a motto:

> If a problem can be solved with a non-llm tool, use the non-llm tool. If necessary, use an llm to generate the non-llm tool.  

Note that this adds an extra step to the solution. Without the tool, this is the pipeline:

$$\text{Natural Language Input}
\xrightarrow{\text{AI does the work}}
\text{Output}$$

But with an intermediate _deterministic_ tool in between it looks like this:

$$\text{Natural Language Input}
\xrightarrow{\text{AI does the translation}}
\text{Structured input}
\xrightarrow{\text{Deterministic tool}}
\text{Output}
$$

For instance, when you ask an assistant to find a piece of text in a large document, it does not put the entirety of the document in its context. Instead, it generates command line options for, say, grep and uses grep to find the text.

In most cases I have seen, the structured input is either a bunch of command line options fed to a command line tool, or a code base fed to a CI pipeline. There is a whole lot of underexplored options out there. 

Here is an example. I wrote a claude skill named [smt-llm-adapter](https://github.com/sonatsuer/smt-llm-adapter) which uses an actual smt solver to solve certain problems instead of Claude "think" on its own. The structured input is the translation of the problem into [MiniZinc](https://www.minizinc.org/) and the deterministic tool is one of the solvers that can process the MiniZinc DSL. This is much more scalable than Claude "thinking hard" and more secure than giving your agent the power to write scripts in a full fledged programming language.

Of course there are all sorts of DSLs to express all sorts of problems which rely on _symbolic methods_. Each such DSL has the potential to be subsumed by AI through a skill. You can even come up with custom ones describing the very specific parts of your business logic.

## A general principle

I want to derive a slogan-like principle from these observations so that I can refer to it later.

Consider the software development motto

> Push preconditions upstream.

It means that in the data flow of your program, validate (or parse) inputs early and if possible enforce them by types or a similar mechanism. If we look at software development pipelines, we see a similar pattern. To increase reliability, we insert deterministic intermediate steps. So one can say that for AI-assisted programming the analogue is

> Push stochasticity upstream.
