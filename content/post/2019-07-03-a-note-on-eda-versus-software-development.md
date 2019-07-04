---
title: A Note on EDA versus Software Development
author: Danny Morris
date: '2019-07-03'
slug: a-note-on-eda-versus-software-development
categories:
  - Software Development
tags:
  - Software Development
---

This summer, I have had the pleasure of mentoring Elan Anderson, an intern who joined through my company's highly-sought summer internship program. He and I are building SimText, an app that performs record linkage using statistial text mining. The core algorithm, which is available as an R package, utilizes the `text2vec` framework for efficient text vectorization, base R for general purpose programming, and some C++ via `Rcpp` for efficient manipulation of sparse matrices. Elan then built a `shiny` web application to enable access to our business users. By far, it is one of neatest projects I've worked on.

While working through the various features of SimText, I was reminded of the different mentalities I use for software development compared with exploratory data analysis (EDA). Minimalism is key when developing software. Minimizing dependencies, complexities in the codebase, and slow bottlenecks make for an application that is easier to deploy, maintain, and use. Writing good tests, even if it's just to measure speed of tricky code blocks, is good for optimizing the application. When I created the first development version of SimText at the beginning of the year, the core algorithm has 11 pacakge dependencies. After a recent refactoring, the core algorithm has only 3.

With exploratory data analysis, you have more freedom to just...explore. The most important thing is gaining a deeper understanding of the data. Aside from being able to reproduce the analysis scientifically, exploratory data analysis carries far less risk than software development. For this reason, code doesn't necessarily need to be optimized, and you can probably get away with extra dependencies that may provide specialized functionality for the analysis.



