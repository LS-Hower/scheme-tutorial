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

我们定义两个操作，分别叫 @${\mathrm{1st}} 和 @${\mathrm{2nd}} ，分别取出序对的第一个和第二个元素。

例：

@$${
  \begin{align*}
    \mathrm{1st} \texttt{(1 . 2)} & \rightarrow \texttt{1} \\
    \mathrm{2nd} \texttt{(1 . 2)} & \rightarrow \texttt{2} \\
    \mathrm{1st} \texttt{(1 . (2 . 3))} & \rightarrow \texttt{1} \\
    \mathrm{2nd} \texttt{(1 . (2 . 3))} & \rightarrow \texttt{(2 . 3)}
  \end{align*}
}

之后要用到。

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

可以发现，我们对列表 @racket[(1 2 3 4)] （别忘了它其实是 @tt{(1 . (2 . (3 . (4 . nil))))} ）分别做 @${\mathrm{1st}} 和 @${\mathrm{2nd}} 操作，会分别得到原子 @racket[1] 和表 @racket[(2 3 4)] （因为它是 @tt{(2 . (3 . (4 . nil)))} ）。以此类推，对只有一个元素的列表 @racket[(4)] 这么做，会分别得到原子 @racket[4] 和表 @racket[()] 。后者是一个有 0 个元素的表，叫“空表”。但如果我们看一下 @racket[(4)] 真正的结构 @tt{(4 . nil)} ，我们就会发现，这个所谓的“空表” @racket[()] 其实刚好就是 @racket[nil] 。我们不再用 @racket[nil] 这种不明不白的东西了，我们改用 @racket[()] 来表示它。例如 @racket[(hello scheme language)] 将会是 @tt{(hello . (scheme . (language . ())))} 。

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

刚刚我们知道，对于嵌套序对，如果最后一个值是空表 @racket[()] ，那么它是表。但显然并非所有嵌套序对都符合这种形式，比如 @tt{(1 . (2 . (3 . 4)))} 。这种序对就叫不适当表。对于这个例子，它的最后一个序对的第二个值是 @racket[4] ，而非空表 @racket[()] 。

注意：“表”（list）和“不适当表”（improper list）是毫无交集的。一个序对，要么是表，要么是不适当表，它是且仅是其中一个。

严格地说，对于一个序对，我们不断地对其进行 @${\mathrm{2nd}} 操作，直至它不是序对。若最终得到的是空表 @racket[()] ，则它是表，否则它是不适当表。还是以 @tt{(1 . (2 . (3 . 4)))} 为例，不断进行 @${\mathrm{2nd}} 操作，一步步地，会产生如下结果：

@verbatim{
(1 . (2 . (3 . 4)))
(2 . (3 . 4))
(3 . 4)
4
}

最后得到的是 @racket[4] 而非空表 @racket[()] ，因此它是不适当表。

不适当表也有它的简写，例如 @tt{(1 . (2 . (3 . 4)))} 简写成 @racket[(1 2 3 . 4)] 。

@verbatim{
(1 . 2)
(a b . c)
(k (1 3) . 4)
}

@subsection{表和不适当表为什么那样简写}

事实上，表和不适当表的简写方式都是由一个简单的规则导出的：

@bold{简写规则} ：若一个点号“ @tt{.} ”后紧跟着一个左括号“ @tt{(} ”，则：

@itemlist[@item{这个点号“ @tt{.} ”}
          @item{这个左括号“ @tt{(} ”}
          @item{与这个左括号配对的右括号“ @tt{)} ”}]

三者能够同时省略。

例如，下面的步骤展示了 @tt{(1 . (2 . (3 . 4)))} 是如何一步步变成简写的：

@verbatim{
(1 . (2 . (3 . 4)))
(1 2 . (3 . 4))
(1 2 3 . 4)
}

所以 @tt{(1 . (2 . (3 . 4)))} 的简写是 @racket[(1 2 3 . 4)] 。上面三种写法都表示完全相同的数据，只是简写的程度不同罢了。理论上，我们写哪一种都是没有错误的，但一般大家都使用最简写法，从来不用别的写法。这就像，虽然数学上我们不是不能写出像

@$${x = \dfrac{\pm \sqrt{-ca4 + b^2} - b}{a2}}

这样的算式（并且别人也不是不能理解），但正常情况下不会有人这么写的。

再举一个 @tt{(1 . (2 . (3 . (4 . ()))))} 的例子：

@verbatim{
(1 . (2 . (3 . (4 . ()))))
(1 2 . (3 . (4 . ())))
(1 2 3 . (4 . ()))
(1 2 3 4 . ())
(1 2 3 4)
}

所以 @tt{(1 . (2 . (3 . (4 . ()))))} 的简写是 @racket[(1 2 3 4)] ，它是一个普通的表。我们可以观察最简写法的结尾处有没有一个点号“ @tt{.} ”来判断是不是不适当表。

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

Scheme 是基于表达式的语言，我们可以将一段代码视为指令，也可以视为表达式。表达式能够被“求值”，得到一个结果，这个结果就是表达式的“返回值”。我们编写特定的程序，控制求值的过程，使它刚好算出我们想要的结果，这就是 Scheme 编程。如果这句话过于抽象让你不太明白，也没关系，看一看下面的例子就明白了。 

@subsection{只是一个数}

如果得到的数据只是一个数，比如 @racket[2.5] 和 @racket[67] ，那么它们的求值结果就是它们本身。

@ss-interaction[2.5 67 10/6]

@subsection[#:tag "evaluate a symbol"]{只是一个符号}

如果得到的数据只是一个符号，那么解释器就把它当成变量的名字，然后去寻找这个名字的变量，将它的值作为求值结果。

例如，刚才我们进行了 @racket[(define pi 3.14)] 这一操作，解释器已经记住，名字叫 @racket[pi] 的变量存有值 @racket[3.14] 。现在如果我们让解释器求值一个符号 @racket[pi] ，那么结果如下：

@ss-interaction[pi]

@subsection{只是一个布尔值}

和数类似，布尔值的求值结果就是本身。

@ss-interaction[#f #t]

@subsection{是一个表，而且首项是 @tt{if}}

@margin-note{像这样，例如“这个表应该有 4 个项”，就是一种“语法规定”。}

如果得到的数据是一个表，而且首项是 @tt{if} ，那么有一个要求：这个表应该有 4 个项。也就是说，它形如 @tt{(if }@italic{<a> <b> <c>}@tt{)} 。

@; 懒了，<a> 和 <b> 之间的空格就不弄成 tt 的了吧。

@margin-note{像这样，对于求值方式的描述，就是一种“语义规定”。}

我们要这样求值：先对表达式 @italic{<a>} 求值，如果得到的值属于真值，则对 @italic{<b>} 求值 ，并将它的结果作为整个表达式的结果；如果得到的值属于假值，则对 @italic{<c>} 求值 ，并将它的结果作为整个表达式的结果。

那么什么是真值，什么是假值呢？显然那两个布尔值肯定无可辩驳， @racket[#t] 属于真值， @racket[#f] 属于假值。Scheme 规定：除 @racket[#f] 之外的一切值都属于真值。因此，这样的值都是真值：

@verbatim{1  2.5  hi  #t  (5 . 3)  (a b c)  ()  0}

@margin-note{Lisp 的其他方言不一定这样规定。例如在 Common Lisp 方言中，空表和假值是同一个东西，空表也是唯一的假值。}

没错，数字 @racket[0] 和空表 @racket[()] 也算真值。唯独 @racket[#f] 是假值。

看一些例子：

@ss-interaction[
(if #t 67 42)
(if 1 67 42)
(if #f 67 42)
(if 67 67 42)
(if (if #t 67 42) 67 42)
]

在最后一个例子里，外层的 @tt{if} 中的 @italic{<a>} 是 @racket[(if #t 67 42)] ， @italic{<b>} 是 @racket[67] ， @italic{<a>} 是 @racket[42] 。先对 @italic{<a>} 求值，得到的是 @racket[67] ；它是真值，所以对 @italic{<b>} 求值，得到的刚好又是 @racket[67] 。

@subsection{是一个表，而且首项是 @tt{define}}

如果得到的数据是一个表，而且首项是 @tt{define} ，那么有一个要求：这个表应该有 3 个项。也就是说，它形如 @tt{(define }@italic{<a> <b>}@tt{)} 。此外还有一个要求： @italic{<a>} 必须是符号。

我们要这样求值：创建一个变量，将 @italic{<a>} 这个符号当作它的名字。对 @italic{<b>} 求值，让这个变量持有这个值。而至于这个 @tt{(define }@italic{<a> <b>}@tt{)} 本身的返回值，它是不确定的。

这个表达式本身所返回的值，我们是不关注的，一般也不会去使用。我们只关注这个表达式执行之后产生的效果（即，创建了一个变量，并将一个值和它绑定）。

@ss-interaction[
(define r 10)
(define k (if #t 1 -1))
]

可以看到，解释器在接收了我们的 @tt{(define }@italic{<a> <b>}@tt{)} 之后甚至没有打印任何东西。因为就像刚才说的，这个表本身的返回值我们并不关注。

接下来，我们只打出符号 @racket[r] 或者 @racket[k] 时，它们就能按照“ @secref["evaluate a symbol"] ”一节中所说的那样被求值了。

@ss-interaction[r k]

当然也可以用在任何需要一个表达式的地方：

@ss-interaction[
(if #t r k)
(if r r k)
(define r-copy r)
r-copy
]

@subsection{是一个表，而且首项……没有撞到像 @tt{define} 和 @tt{if} 之类的关键词}

刚才的两节让我们意识到，Scheme 有着类似于“关键字”“保留字”的东西，比如 @tt{define} 和 @tt{if} 。它们一旦出现在表的开头，就意味着表的接下来的东西要符合特定规则，而且求值规则都得特殊说明，有什么效果也要特殊说明。事实上 Scheme 还有 @tt{let} 、 @tt{cond} 和 @tt{lambda} 等关键字。于是就有了如下的空子。

如果得到的数据是一个表，而且首项不和任何一个关键词相同（甚至可以不是符号），那么该如何求值呢。

此时，对它的形式几乎没有要求，比如说并不会限制这个表有几个项。也就是说，它形如 @tt{(}@${<t_0> \, <t_1> \, <t_2> \, \ldots \, <t_n>}@tt{)} 。这里有 @${n+1} 个项。

我们要这样求值：对 @${<t_0>} 、 @${<t_1>} 等 @${n+1} 个项全都分别求值一下。 @${<t_0>} 所求出的结果应当是一个函数，它应当能接受 @${n} 个参数。然后将后面那 @${n} 个项，即 @${<t_1> \, <t_2> \, \ldots \, <t_n>} ，作为参数，调用这个函数。函数所返回的结果，就是整个表的求值结果。

@bold{我们这里用了“函数”这个名称，但 Scheme 这里一般用“过程”这个名称。接下来我们也会一直用“过程”这个称呼。}

例如，假设我们有一个变量 @racket[f] ，它的值是一个过程。这个过程接收 3 个参数，不妨叫作 @${a} 、 @${b} 和 @${c} 。它能计算 @${a + 2b + 3c} 的值，将这个值作为结果返回出来。那么，如果我们有一个 4 个项的表，其中首项是符号 @racket[f] ，接下来的三项分别是 @racket[3] 、 @racket[1] 和 @racket[2] ，那么对它求值的结果就将是 @racket[11] 。

@; 偷偷在解释器里定义一下，方便接下来演示

@(void (interaction-eval #:eval ss-eval
                         (define (f a b c)
                           (+ a
                              (* 2 b)
                              (* 3 c)))
                         (define (g a b c)
                           (+ a
                              (* 3 b)
                              (* 2 c)))))

@ss-interaction[(f 3 1 2)]

当然，还是那句话：需要表达式的地方往往可以写任何形式的表达式，只要能求值就行。所以这样写也是可以的（顺便为了方便阅读，4 个项我们竖着写了）：

@ss-interaction[
(f
 (if #t 3 0)
 (if #f 0 1)
 (if #t 2 0))
]

但这时候第一个项 @racket[f] 说：你们都玩起 @tt{if} 来了，我凭什么不能玩？

我们假设我们又有一个变量 @racket[g] ，它跟 @racket[f] 差不多，但计算的是 @${a + 3b + 2c} 。口算一下， @racket[(g 3 1 2)] 的求值结果就应该是 @racket[10] 。

@ss-interaction[(g 3 1 2)]

我们当然可以对首项也玩 @tt{if} ：

@ss-interaction[
((if #t f g)
 3
 1
 2)
]

在这里，我们在调用过程之前要先对 @racket[(if #t f g)] 求值，结果是 @racket[f] 。接下来就跟求值 @racket[(f 3 1 2)] 一样了。

如果把 @racket[#t] 改成 @racket[#f] ：

@ss-interaction[
((if #f f g)
 3
 1
 2)
]

这次就是跟求值 @racket[(g 3 1 2)] 一样。

Scheme 内置了许多有用的过程，它们当然都有自己的名字。比如说，四则运算都是过程。

@racket[+] 是一个符号，它的值是一个过程，能够取任意多个参数，算出它们的总和。

@ss-interaction[(+ 1 2) (+ 1.5 2.5 10.4) (+ 3/7 6/11 4)]

@racket[-] 是一个符号，它的值是一个过程，取两个参数，算出它们的差。

@ss-interaction[(- 1 2) (- 1.5 2.5) (- 3/7 6/11)]

@racket[*] 是一个符号，它的值是一个过程，能够取任意多个参数，算出它们的乘积。

@ss-interaction[(* 1 2) (* 1.5 2.5 10.4) (* 3/7 6/11 4)]

@racket[/] 是一个符号，它的值是一个过程，取两个参数，算出它们的商。

@ss-interaction[(/ 1 2) (/ 1.5 2.5) (/ 3/7 6/11)]

还有一些常用数学函数。

@ss-interaction[
(sqrt 4)
(sqrt 2)
(/ (- (sqrt 5) 1) 2)
(sin 1)
(cos 1)
(/ (sin 1) (cos 1))
(tan 1)
(asin (sin 1))
(exp 1)
(/ (exp 2) (exp 1))
]

除了运算之外，还有比较操作。

@racket[<] 是一个符号，它的值是一个过程，取至少 2 个参数，判断前面的项是否小于后面的项。例如， @racket[(< 2 3 5)] 判断“ @${2 < 3} 且 @${3 < 5} ”是否成立。还有 @racket[>] 、 @racket[<=] 、 @racket[>=] 、 @racket[=] 过程与之类似。

@ss-interaction[
(< 2 3 5)
(< 2 3)
(< 3 2)
(> 3 2)
(= 5 5)
(= 5 6)
]


以上都是对数值做的操作。Scheme 的内置函数库当然不止这些。我们再举一些对表的操作的例子：

@itemlist[@item{@racket[null?] 过程接收 1 个参数，判断它是不是空表；}
          @item{@racket[car] 过程接收 1 个参数（它应当是序对），给出这个序对的第一个元素（其实就是 @${\mathrm{1st}} 操作）；}
          @item{@racket[cdr] 过程接收 1 个参数（它应当是序对），给出这个序对的第二个元素（其实就是 @${\mathrm{2nd}} 操作）；}]

TODO: car 和 cdr 名字由来

比如，如果我们有一个变量 @racket[ls] ，它持有的值是一个表 @racket[(1 2 3 4)] 。

@(void (interaction-eval #:eval ss-eval
                         (define ls '(1 2 3 4))))

@ss-interaction[ls]

别忘了 @racket[(1 2 3 4)] 实质上是用序对表示的，是 @tt{(1 . (2 . (3 . (4 . ()))))} 。所以，如果分别传递给 @racket[car] 和 @racket[cdr] 之后，我们期望的结果应分别是 @racket[1] 和 @tt{(2 . (3 . (4 . ())))} ，后者也就是 @racket[(2 3 4)] 。

@ss-interaction[(car ls) (cdr ls)]

等等，这个 @racket[ls] 的内容居然是表，而不是一个简单的数值。那么它是怎么定义出来的？我们还不知道任何手段能求值求出一个表呢。之前学习的数据中，数值和布尔值，如 @racket[67] 和 @racket[#f] ，我们都能够直接表示出来了；但像 @racket[(1 2 3)] 或者 @racket[(a b . c)] 这样的数据，以及单个的符号（如 @racket[pi] ），我们还不知道怎样将它们搬过来。也就是说：

@itemlist[
  @item{
    如果我们直接写出整数 @racket[67] 试图得到一个整数，那么没问题：

    @ss-interaction[67]
  }
  @item{
    如果我们直接写出布尔值 @racket[#f] 试图得到一个布尔值，那么没问题：

    @ss-interaction[#f]
  }
  @item{
    如果我们直接写出表 @racket[(1 2 3 4)] 试图得到一个表，那就有问题了。对 @racket[(1 2 3 4)] 求值可没办法得到这个表本身。求值必须得按照这一节里刚讲过的规则做，也就是：首先将 @racket[1] 当成过程，然后试图把后面 3 个数应用于它。然后就报错了。因为 @racket[1] 可不是一个过程。我们得不到一个表，只得到了报错。

    @ss-interaction[(1 2 3 4)]

    我们就是拿不到“表”这种数据。
  }
  @item{
    如果我们直接写出符号 @racket[pi] 试图得到一个符号，那也有问题了。解释器会按照“ @secref["evaluate a symbol"] ”一节中所说的规则做：首先查找名为 @racket[pi] 的变量，找到它的值是 @racket[3.14] ，所以给出了 @racket[3.14] 。我们得不到一个符号，只得到了浮点数。

    @ss-interaction[pi]

    如果这个变量没有定义过，那更是会直接报错“变量未定义”了。

    @ss-interaction[hello]

    总之我们就是拿不到“符号”这种数据。
  }
]

为了解决这个问题，我们只需再引入一个新的关键字及其对应的规则即可，见下。

