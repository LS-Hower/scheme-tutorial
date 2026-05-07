#lang scribble/manual

@title{数据导向的 Scheme 教程}

@author[(author+email "LS_Hower" "ls.hower06@gmail.com")]

@; ----------------------------------------------------------------------

@(require scribble-math
          scribble/eval)

@(define ss-eval (make-base-eval))

@(define-syntax-rule (ss-interaction e ...)
   (interaction #:eval ss-eval e ...))

@(use-mathjax)

@; ----------------------------------------------------------------------

@hyperlink["../index.html"]{返回博客主页面}

@hyperlink["https://github.com/LS-Hower/scheme-tutorial"]{本项目 GitHub 仓库}

@; ----------------------------------------------------------------------

@section{背景}

Lisp 是一门上古编程语言，诞生于 1958 年，有很多变体（即方言）。

Scheme 是其中重要的一簇方言的代表。

Racket 是 Scheme 的一个实现。现在这个文档也是使用 Racket 制作的。

@section{数据的规则}

数据分为原子和序对两种。

@subsection{原子}

我们有整数。

@verbatim{42    67    0     -3    +7}

我们有有理数。

@verbatim{4/5   6/10  -3/8  -4/3  100/3}

Racket 满足你的一些愿望，比如有理数能自动化为最简。

我们有浮点数。

@verbatim{0.0   -2.8  3.14}

我们有布尔值。

@verbatim{#t    #f}

我们有符号（symbol）。这里给出 9 个例子：

@verbatim{
lambda               q
list->vector         soup
+                    V17a
<=?                  a34kTMNs
the-word-recursion-has-many-meanings
}

可以看到，这比 C 语言中标识符的规则要宽松得多了。

@subsection{序对}

我们有序对（pair）。它能把两个东西 @italic{<a>} 和 @italic{<b>} 打包在一起。结果记作 @tt{(}@italic{<a>}@tt{ . }@italic{<b>}@tt{)} 。

@verbatim{
(1 . 2)
(0 . 0)
(hello . world)
(six-seven . 67)
(- . -)
}

序对可以嵌套。

@verbatim{
(1 . (2 . 3))
(1 . (2 . (3 . 4)))
}

只用序对就能表达一切数据结构了，比如列表。见下。

@subsection{表}

我们要有表（list）。表也叫列表。

列表要怎么用序对表达出来？比如我们想要一个拥有 4 个元素的表，元素分别是 @racket[1] ， @racket[2] ， @racket[3] 和 @racket[4] ，它要怎么用序对表示？刚才的嵌套序对：

@verbatim{(1 . (2 . (3 . 4)))}

似乎是一个不错的想法，但我们决定不这么做，部分原因是这样无法表示空列表。我们要用

@verbatim{(1 . (2 . (3 . (4 . nil))))}

来表示。这里的 @racket[nil] 是一个特殊值，表示“表的尾部”。

所以表都是序对。（这句话还不完全正确， @racket[nil] 的事情稍后再说。）

表很常见，所以我们有简写，例如 @bold{上面的表简写成 @racket[(1 2 3 4)]} 。

可以发现，我们对列表 @racket[(1 2 3 4)] （别忘了它其实是 @tt{(1 . (2 . (3 . (4 . nil))))} ）分别做“取出序对的第一个元素”和“取出序对的第二个元素”操作，会分别得到原子 @racket[1] 和表 @racket[(2 3 4)] （因为它是 @tt{(2 . (3 . (4 . nil)))} ）。以此类推，对只有一个元素的列表 @racket[(4)] 这么做，会分别得到原子 @racket[4] 和表 @racket[()] 。后者是一个有 0 个元素的表，叫“空表”。但如果我们看一下 @racket[(4)] 真正的结构 @tt{(4 . nil)} ，我们就会发现，这个所谓的“空表” @racket[()] 其实刚好就是 @racket[nil] 。我们不再用 @racket[nil] 这种不明不白的东西了，我们改用 @racket[()] 来表示它。例如 @racket[(hello scheme language)] 将会是 @tt{(hello . (scheme . (language . ())))} 。

所以表要么是序对，要么是空表 @racket[()] 。后者并不是一个序对，而是视为一个原子。

更多表的例子：

@verbatim{
(hello 42)
(f a b c)
(#t #t #f)
}

再强调一次，注意 @racket[(hello 42)] 与 @racket[(hello . 42)] 的不同。前者其实是 @tt{(hello . (42 . ()))} ，它是表，也是序对；后者只是一个普通的序对，不是合法的表。

表的元素当然也可以是表：

@verbatim{
(def (fun x) x)
(1 (2 3) (4 5 6) 7 (8) 9)
}

@subsection{不适当表}

我们有不适当表（improper list）。

刚刚我们知道，有些序对是表，有些不是。后者就叫不适当表。不适当表其实也有简写： @tt{(1 . (2 . (3 . 4)))} 会简写成 @racket[(1 2 3 . 4)] 。

TODO：简写的原因，由“.”与“()”的对消导出

@verbatim{
(1 . 2)
(a b . c)
}

@subsection{总结}

正如这一节开头所说，原子和序对统称为数据。（别忘了，刚才的表要么是序对，要么是空表，而空表是一个原子。所以表也都是数据。）

@verbatim{
(1 2 3 4)
233
wow
(maybe (average 2 3))
(T . T)
}

总览：

@$$|{
  \phantom{\texttt{67}}        \quad
  \phantom{\texttt{#t}}        \quad
  \phantom{\texttt{3.14}}      \quad
  \phantom{\texttt{abc}}       \quad
  \overbrace{
    \phantom{\texttt{()}}      \quad
    \phantom{\texttt{(1 2 3)}}
  }^{\text{list}}              \quad
  \overbrace{
    \phantom{\texttt{(a . b)}} \quad
    \phantom{\texttt{(1 2 . 3)}}
  }^{\text{improper list}}
  \\
  \texttt{67}      \quad
  \texttt{#t}      \quad
  \texttt{3.14}    \quad
  \texttt{abc}     \quad
  \texttt{()}      \quad
  \texttt{(1 2 3)} \quad
  \texttt{(a . b)} \quad
  \texttt{(1 2 . 3)}
  \\
  \underbrace{
    \phantom{\texttt{67}}      \quad
    \phantom{\texttt{#t}}      \quad
    \phantom{\texttt{3.14}}    \quad
    \phantom{\texttt{abc}}     \quad
    \phantom{\texttt{()}}
  }_{\text{atom}}              \quad
  \underbrace{
    \phantom{\texttt{(1 2 3)}} \quad
    \phantom{\texttt{(a . b)}} \quad
    \phantom{\texttt{(1 2 . 3)}}
  }_{\text{pair}}
}|

别忘了， @racket[(1 2 3)] 其实是 @tt{(1 . (2 . (3 . ())))} 的简写， @racket[(1 2 . 3)] 其实是 @tt{(1 . (2 . 3))} 的简写。

@section{代码的规则}

所有的程序都是数据的序列。程序的样子都符合数据序列的样子。比如下面这些东西（暂时不用理解它们表达的意思，只需要看它们的形式）：

@verbatim{
(define (square x) (* x x))
(define pi 3.14)
pi
(display pi)
(display (square pi))
}

这说白了就是 5 个数据罢了。先是 2 个表，然后是 1 个原子，然后又是 2 个表。

所以说，数据如果符合特别的规定，就能够被解读成指令（代码）。比方说，如果一个表只有 3 个元素，而且

@itemlist[@item{首个元素是符号 @racket[define] ，}
          @item{第二个元素是符号 @racket[pi] ，}
          @item{第三个元素是一个数值 @racket[3.14] ，}]

（所以这个表其实就是 @racket[(define pi 3.14)] ，）

那么它就是一条正确的指令（代码），意思是：“定义一个变量，它的名称是 @racket[pi] ，它的值将是 @racket[3.14] ”。

又比如，如果一个数据就只是一个单独一个符号 @racket[pi] ，那么它就是一条正确的指令（代码），意思是：“给出名称为 @racket[pi] 的变量的值”。

我们现在可以拿出 Scheme 交互式解释器试试看。

@ss-interaction[
(define pi 3.14)
pi
]

可以看到，在输入了 @racket[(define pi 3.14)] 之后，我们再输入一个 @racket[pi] ，解释器就输出了 @racket[3.14] 作为答案。

Scheme 是极简语言，所以像这样的规定非常少，十分钟内就可以把该学的学完。

这样的规定就是“语法”和“语义”。语法告诉我们，能被解读成代码的数据，应该符合什么样的形式、有着什么样的结构（比如刚才说的“表的首个元素是符号 @racket[define] ”）。而语义告诉我们，解读出的代码是做什么事的（比如刚才说的“定义一个变量”）。


TODO
