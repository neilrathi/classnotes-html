# `classnotes-html`
_markdown-to-html for lectures_

This is a pipeline for writing notes in markdown and converting them to pretty pseudo-LaTeX'd HTML.[^1] It comes with KaTeX, 'interactive' functions, and pre-defined theorem environments. It is based on my LaTeX package [classnotes](https://github.com/neilrathi/classnotes).

Obviously there is a reasonable amount going on behind-the-scenes, but most of the work is done with pandoc. To transform a markdown doc into HTML, run[^2]
```bash
pandoc -c style.css --include-in-header header.html --katex --lua-filter=filter.lua -s FILE.md -o FILE.html
```

This source file is available on [Github](https://github.com/neilrathi/classnotes-html/blob/main/docs.md).

## Usage

There are four custom 'theorem-like' environments: `thrm`, `defn`, `postulate`, and `lemma`. Use \`\`\``env` delimiters to initialize these. Numbering is automatically incremented.

```defn
A loss function $J : \Theta \to \mathbf{R}$ is a _distance metric_ that quantifies how far functions parametrized by $\theta$ deviate in their output from an oracle.
```

Display math uses double dollar \$\$ wrappers.[^3] Say we have a function
$$
J(\theta) = \frac{1}{2N} \sum_{i=1}^{N} \left(h_{\theta}(x^{(i)}) - y^{(i)}\right)^2
$$
which we would like to minimize. We can do this in a Python code cell, wrapped with the \`\`\``python` delimiter as below:

```python
import numpy as np

X = np.array([[1, 1], [1, 2], [2, 2], [2, 3]])
y = np.array([6, 8, 9, 11])

w = np.zeros(X.shape[1])
lr = 0.01

for _ in range(1000):
    w -= lr * X.T.dot(X.dot(w) - y) / len(y)

print(w)
```

Graphs are automatically constructed from equations using the Desmos API.

```{.graph left=-4 right=4 bottom=-2 top=2 caption="Overfitting"}
[(-2,-0.9),(-1,-0.6),(2,0.8),(-0.05,0.05)]
y = 0.5x
y=-0.0757875x^3-0.0341208x^2+0.72815x+0.0864833
```

Tables and figures use standard markdown syntax. You can also use gifs.

![Constructing $\theta$ from $\cos\theta$](./angle_from_cosine.gif "Constructing θ from cosθ")

Tables are rendered as in the `booktabs` package.

Column 1 | Column 2
----- | ------
hello | goodbye
wahoo | wahooo

## Implementation Details
Pandoc is doing most of the conversion. The `style.css` file contains all CSS used; most of this is standard. I use CSS3 counters to auto-number definitions/figures/etc. `header.html` imports important KaTeX information.

The Lua file `filter.lua` deals with converting shorthand environments into the underlying HTML divs. Code cells are implemented with [SageCell](https://sagecell.sagemath.org).

[^1]: HTML is a nice alternative to LaTeX because it supports, among other things, interactive notes: editable / runnable code, interactive graphs, animated figures. Markdown is also easier to write than LaTeX.
[^2]: You can also set up an alias in your `~/.bashrc` file.
[^3]: Inline math uses single dollar signs. Bracket syntax for display math is not supported.
