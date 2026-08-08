---
layout: post
title: "Some intuition behind fundamental solutions and Green's functions"
categories: blog
excerpt: Green's functions are pretty useful, but can seem a bit confusing for newcomers since they seem like an arbitrary definition. Here's some intuition.
tags: [bie, integral, pde]
date: 2021-04-16
---

# Summary
 Green's functions and fundamental solutions are a useful tool to solve partial differential equations (PDEs), particularly the linear, constant coefficient ones.
 In math courses, they're used mostly as an analytic tool, but they also enable some cool numerical techniques for physical simulations.
In these courses (and most textbooks), Green's functions are usually just defined without much intuition, then used to solve problems and prove theorems.
This is fairly uninspiring, but I recently found an [answer on MathOverflow](https://math.stackexchange.com/a/1738322) that more clearly motivates the definition.

## First, some linear algebra
Before even discussing PDEs, let's discuss a standard method of solving a system of linear equations,
\begin{equation}
A\mathbf{x} = \mathbf{b}
\end{equation}
where $$A$$ is an $$m \times n$$ matrix with linearly independent columns and $$\mathbf{x}$$ and $$\mathbf{b}$$ are $$n$$- and $$m$$-dimensional vectors, respectively.
We can take the standard basis vectors $$\mathbf{e}_i$$ in $$\mathbb{R}^m$$ (real $$m$$-vectors whose $$i$$th component is 1 with zero elsewhere) and rewrite $$\mathbf{b}$$ as:
\begin{equation}
\mathbf{b}=b_1\mathbf{e}\_1 + b_2\mathbf{e}\_2 + \dots +b_m\mathbf{e}\_m, 
\end{equation}
where $$b_i$$ is the $$i$$th component of $$\mathbf{b}$$.
Since our equation is linear, we know [from linear algebra](https://en.wikipedia.org/wiki/Inverse_element#Matrices) that if we can solve the $$m$$ linear systems $$A \mathbf{x}^{(i)} = \mathbf{e}_i$$ for $$\mathbf{x}^{(i)}$$, then we know the solution for all possible $$\mathbf{b}$$'s,
\begin{equation}
   \mathbf{x} = b_1 \mathbf{x}^{(1)} + b_2 \mathbf{x}^{(2)} + \dots +  b_m \mathbf{x}^{(m)}. 
\end{equation}
Another way to say this is that each $$\mathbf{x}^{(i)}$$ is a column of the right inverse of $$A$$.
Hopefully, this is not too surprising.

## To infinity and beyond
Let's write down the PDE that we want to solve:
\begin{equation}
Lu(\mathbf{x}) = f(\mathbf{x}),\quad \mathrm{for}\, \mathbf{x} \in \mathbb{R}^n 
\end{equation}
$$L$$ is a linear constant-coefficient second order differential operator ( such as $$\frac{d^2}{dx^2}$$, $$\Delta$$, or something scarier), while $$u(\mathbf{x})$$ and $$f(\mathbf{x})$$ are functions.
This looks suspiciously like our linear system above with one main difference: we are solving for a function in an infinite dimensional space (the space of $$C^2$$ functions on $$\mathbb{R}^n$$) instead of a finite vector in a finite dimensional space.
This has a couple consequences:
   1. The inner product is rather different. 
        While $$\langle \mathbf{a},\mathbf{b} \rangle = \mathbf{a} \cdot \mathbf{b} $$ for finite vectors, for functions $$f$$ and $$g$$, the inner product between them is
        \begin{equation}
        \langle f,g \rangle = \int_{\mathbb{R}^n} f(\mathbf{x}) g(\mathbf{x}) d\mathbf{x}
        \end{equation}
    This means that we need to deal with integrals rather than finite sums. 
   2.  We don't have a finite set of basis vectors any more, so how to do we decompose functions in an analogous fashion?
    While we could choose an infinite basis, there is a more convenient alternative called the *Dirac delta function* $$\delta(\mathbf{x})$$, which is defined heuristically as
   <!---$$ \delta(\mathbf{x}) = \begin{cases} \infty  & \mathbf{x}=0 \\ 0 & \text{otherwise} \end{cases}, \quad \int_{\mathbb{R}^n} \delta(\mathbf{x}) = 1.  $$-->
   $$ \delta(\mathbf{x}) = \infty$$ if $$\mathbf{x}=0$$ and zero otherwise, while satisfying $$\int_{\mathbb{R}^n} \delta(\mathbf{x}) = 1.  $$
    Technically, the delta function is *not* a function; it can be properly defined as a [measure](https://en.wikipedia.org/wiki/Dirac_delta_function#As_a_measure) or [distribution](https://en.wikipedia.org/wiki/Dirac_delta_function#As_a_distribution).
    But $$\delta(\mathbf{x})$$ has the following useful property:
    \begin{equation}
    f(\mathbf{x}) = \int_{\mathbb{R}^n} f(\mathbf{y})\delta(\mathbf{y}-\mathbf{x}) d\mathbf{y},
    \end{equation}
    which is an inner product between $$f$$ and a delta function shifted by $$\mathbf{x}$$.

This is nice because we have a compact representation for arbitrary functions.
This is not so nice because now we have to compute infinite integrals involving $$\delta(\mathbf{x})$$.
It seems that we made things more complicated, but we can use this form to decompose our PDE into a set of problems in terms of $$\delta(\mathbf{x})$$.

## Comparing the two setups
Now let's compare the forms of the representation of a discrete vector in terms of a basis set
\begin{equation}
\mathbf{b}=b_1\mathbf{e}\_1 + b_2\mathbf{e}\_2 + \dots +b_m\mathbf{e}\_m = \sum_{i=1}^m b_i \mathbf{e}\_i,
\end{equation}
and the representation of a function in terms of a delta function
\begin{equation}
f(\mathbf{x}) = \int_{\mathbb{R}^n} f(\mathbf{y})\delta(\mathbf{y}-\mathbf{x}) d\mathbf{y}.
\end{equation}
These are looking pretty similar if you squint.
The continuous analogue of the summation is the integral.
For each value of $$i$$ in the discrete case and each $$\mathbf{y}$$ in the continuous one, $$f(\mathbf{y})$$ is acting like $$b_i$$, since both values are determined by $$f$$ and $$\mathbf{b}$$, respectively.
Meanwhile, $$\delta(\mathbf{y}-\mathbf{x})$$ is acting like $$\mathbf{e}_i$$, since both are independent of $$f$$ and $$\mathbf{b}$$ respectively.

For the linear system, we solve the $$m$$ linear systems $$A\mathbf{x}^{(i)} = \mathbf{e}_i$$ for a set of vectors $$\mathbf{x}^{(i)}$$.
In the PDE setting, we want to do something similar: we want to solve the PDE for a set of functions $$F_\mathbf{y}(\mathbf{x})$$, parametrized by $$\mathbf{y}$$, with the right hand side equal to $$\delta(\mathbf{y}-\mathbf{x})$$:
\begin{equation}
LF_\mathbf{y}(\mathbf{x}) = \delta(\mathbf{y}-\mathbf{x}),\quad \text{for } \mathbf{x},\mathbf{y}, \in \mathbb{R}^n
\end{equation}

If we can actually compute $$F_\mathbf{y}(\mathbf{x})$$, we can similarly reconstruct $$u$$ with an inner product:
\begin{equation}
u(\mathbf{x}) = \int_{\mathbb{R^n}} F_\mathbf{y}(\mathbf{x})f(\mathbf{y})d\mathbf{y}
\end{equation}
In other words, we can represent the solution $$u(\mathbf{x})$$ as an inner product between $$F_\mathbf{y}(\mathbf{x})$$ and $$f(\mathbf{y})$$ as functions of $$\mathbf{y}$$.
We can once again compare this formula to the discrete case:
\begin{equation}
   \mathbf{x} = b_1 \mathbf{x}^{(1)} + b_2 \mathbf{x}^{(2)} + \dots +  b_m \mathbf{x}^{(m)}.
\end{equation}
Again $$f(\mathbf{y})$$ serves the role of $$b_i$$ in the continuous setting, while $$F_\mathbf{y}(\mathbf{x})$$ is acting like $$\mathbf{x}^{(i)}$$.

To see why this representation of $$u$$ works, we can start with our set of equation $$LF_\mathbf{y}(\mathbf{x}) = \delta(\mathbf{y}-\mathbf{x})$$, multiply both sides by $$f(\mathbf{y})$$ and integrate with respect to $$\mathbf{y}$$:
\begin{equation}
\int_{\mathbb{R^n}} L\left(F_\mathbf{y}(\mathbf{x})\right)f(\mathbf{y}) d\mathbf{y} = \int_{\mathbb{R^n}} \delta(\mathbf{y}-\mathbf{x}) f(\mathbf{y}) d\mathbf{y}.
\end{equation}
We can [bring the integral inside of the differential operator](https://en.wikipedia.org/wiki/Leibniz_integral_rule) $$L$$ because it's independent of $$\mathbf{x}$$:
\begin{equation}
L \left[\int_{\mathbb{R^n}} F_\mathbf{y}(\mathbf{x})f(\mathbf{y}) d\mathbf{y} \right] = \int_{\mathbb{R^n}} \delta(\mathbf{y}-\mathbf{x}) f(\mathbf{y}) d\mathbf{y},
\end{equation}
and since the right hand side is equal to our definition of $$f(\mathbf{x})$$ above, we're left with
\begin{equation}
L \left[\int_{\mathbb{R^n}} F_\mathbf{y}(\mathbf{x})f(\mathbf{y}) d\mathbf{y} \right] = f(\mathbf{x}).
\end{equation}
Comparing this equation with $$Lu=f$$, we see that $$u(\mathbf{x})$$ must equal the integral in the braces.

This function $$F_\mathbf{y}(\mathbf{x})$$ is called the *fundamental solution* of the differential operator $$L$$.
People usually write $$F_\mathbf{y}(\mathbf{x})$$ as $$F(\mathbf{x},\mathbf{y})$$ or, confusingly, $$G(\mathbf{x},\mathbf{y})$$; we're just solidifying the linear algebra analogy with the $$\mathbf{y}$$ subscript here.

## What about boundary conditions?

Most PDEs have boundary conditions of some sort, so how does the fundamental solution fit into this setting?
Our PDE looks like this:
\begin{equation}
Lu = f,\quad  \text{for } \mathbf{x} \in \Omega \subset \mathbb{R}^n
\end{equation}
with either
\begin{equation}
u = g_D,\quad  \text{for } \mathbf{x} \in \partial\Omega = \Gamma 
\end{equation}
for Dirichlet problems or 
\begin{equation}
\nabla_\mathbf{x} u(\mathbf{x}) \cdot n(\mathbf{x}) = g_N(\mathbf{x}),\quad  \text{for } \mathbf{x} \in \partial\Omega = \Gamma 
\end{equation}
for Neumann problems, where $$\Omega$$ is a closed bounded domain with a $$C^2$$ boundary $$\partial\Omega= \Gamma$$ (details in [Kress](https://www.amazon.com/Integral-Equations-Applied-Mathematical-Sciences/dp/3642971482)).
Note that $$\nabla_\mathbf{x}$$ is the gradient operator with respect to the $$\mathbf{x}$$ variable.
For the sake of concreteness, in this section, we'll choose $$L = -\Delta$$, i.e., we're solving a Poisson problem (or a Laplace problem if $$f=0$$). 
[Mixed boundary conditions](https://en.wikipedia.org/wiki/Robin_boundary_condition) are also possible but I can't remember the correct reference for the derivation.

Without getting into too much symbol pushing, since $$u$$ is harmonic (satisfies $$\Delta u = 0$$), Green's [second](https://en.wikipedia.org/wiki/Green%27s_identities#On_manifolds) and [third](https://en.wikipedia.org/wiki/Green%27s_identities#Green's_third_identity) identities tell us that we can write down the solution $$u$$ as a sum of different integrals.

\begin{equation}
u(\mathbf{x}) = \int_\Omega G_\mathbf{y}(\mathbf{x})f(\mathbf{y})dy + \int_{\Gamma} G_\mathbf{y}(\mathbf{x}) \left(\nabla_\mathbf{y} u(\mathbf{y})\cdot n(\mathbf{y})\right) d\Gamma_\mathbf{y} - \int_{\Gamma} \left(\nabla_\mathbf{y} G_\mathbf{y}(\mathbf{x})\cdot n(\mathbf{y})\right) u(\mathbf{y}) d\Gamma_\mathbf{y},
\end{equation}

The details of the formula are on the first page of [these lecture notes](https://web.stanford.edu/class/math220b/handouts/greensfcns.pdf) (apply the [second identity](https://en.wikipedia.org/wiki/Green%27s_identities#On_manifolds) one twice, interchanging the roles of $$u$$ and $$G$$, then plug in $$u=f$$ in $$\Omega$$ and the boundary conditions for the integrals over $$\Gamma$$).
The second integral is where the Neumann boundary condition contributes to the solution and the third integral incorporates the Dirichlet information (by plugging in values of $$\left(\nabla_\mathbf{y} u(\mathbf{y})\cdot n(\mathbf{y})\right)$$ and $$u(\mathbf{x})$$ on the boundary, respectively).

The first integral in this formula gives us hope, since it is identical to our fundamental solution representation of the PDE without boundary conditions: maybe we can just use $$F_\mathbf{y}(\mathbf{x})$$?
Unfortunately, $$F_\mathbf{y}(\mathbf{x})$$ was derived without a boundary condition, so we need to find a new function.
#### What is $$G_\mathbf{y}(\mathbf{x})$$?
We need to solve a new family of PDEs for $$G_\mathbf{y}(\mathbf{x})$$, but the PDE looks suspiciously familiar:
\begin{equation}
-\nabla G_\mathbf{y}(\mathbf{x}) = \delta(\mathbf{y}-\mathbf{x}),\quad  \text{for } \mathbf{x},\mathbf{y} \in \Omega \subset \mathbb{R}^n
\end{equation}
But for boundary conditions, we use 
\begin{equation}
G_\mathbf{y}(\mathbf{x}) = 0,\quad  \text{for } \mathbf{y} \in \partial\Omega,
\end{equation}
for Dirichlet conditions, and for Neumann problems, we use
\begin{equation}
\nabla G_\mathbf{y}(\mathbf{x}) \cdot n(\mathbf{y}) = 0,\quad  \text{for } \mathbf{y} \in \partial\Omega.
\end{equation}

Conveniently, if we plug the corresponding boundary condition for $$G_\mathbf{y}$$ into the integrals above, we're left with one of the two integrals over the boundary, containing the boundary condition for $$u$$ that we actually have. 
The Dirichlet condition $$G_\mathbf{y}(\mathbf{x}) =0$$ kills the integral over $$\nabla_\mathbf{y} u(\mathbf{y})\cdot n(\mathbf{y})$$ (which is the Neumann condition) and vice versa for the Neumann case. So that's nice!

The question still remains: what is $$G_\mathbf{y}(\mathbf{x})$$? 
It turns out that the right thing to do [(see page 3)](https://web.stanford.edu/class/math220b/handouts/greensfcns.pdf) is to choose 
\begin{equation}
G_\mathbf{y}(\mathbf{x}) = F_\mathbf{y}(\mathbf{x}) - C_\mathbf{y}(\mathbf{x}),
\end{equation}
where $$C_\mathbf{y}(\mathbf{x})$$ satisfies yet another PDE:
\begin{equation}
-\Delta_\mathbf{y} C_\mathbf{y}(\mathbf{x}) = 0,\quad  \text{for } \mathbf{x},\mathbf{y} \in \Omega \subset \mathbb{R}^n
\end{equation}
with 
\begin{equation}
C_\mathbf{y}(\mathbf{x}) = F_\mathbf{y}(\mathbf{x}),\quad  \text{for } \mathbf{y} \in  \Gamma 
\end{equation}
for Dirichlet problems or 
\begin{equation}
\nabla_\mathbf{y} C_\mathbf{y}(\mathbf{x}) \cdot n(\mathbf{y}) = \nabla_\mathbf{y} F_\mathbf{y}(\mathbf{x}) \cdot n(\mathbf{y}),\quad  \text{for } \mathbf{y} \in \Gamma 
\end{equation}
for Neumann ones.
This looks more confusing, but it really just means: **let's use the fundamental solution for the free space PDE and subtract off a correction term to make sure it has the value we want on the boundary.** Since the PDEs involved are linear, all of this works out ok.

The function $$G_\mathbf{y}(\mathbf{x})$$ is called the *Green's function* of the differential operator $$L$$. It's usually written as $$G(\mathbf{x},\mathbf{y})$$. They're also sometimes referred to as the *kernel* of the PDE.
Although we specialized the argument above for a Laplace problem, the same reasoning holds for Stokes, Helmholtz, elasticity, and many other PDEs.

#### Ok, but what actually *are* these functions concretely?
Unfortunately, you need to work out $$F_\mathbf{y}(\mathbf{x})$$ and $$G_\mathbf{y}(\mathbf{x})$$ for each PDE. 
For many PDEs, the Green's functions are [usually worked out already](https://en.wikipedia.org/wiki/Green%27s_function#Table_of_Green's_functions).
In a future post, I'll list a few with some code snippets.

A short disclaimer: technically, everything in this post should have been discussed in the context of distributions, distributional derivatives, etc, since $$\delta(\mathbf{x})$$ isn't a function. 
This would be more correct at the expense of needless complexity.
