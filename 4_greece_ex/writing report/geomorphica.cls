% Documentclass geomorphica.cls for Geomorphica, a community-driven, Diamond Open Access journal publishing peer-reviewed research in geomorphology.

% Current version with inputs from:
% Roberto Fernández (Roberto@psu.edu) - May, 2023
%
% Based on the class for Seismica (www.seismica.org) 
% and used with their authorization. 
% Seismica class developed with inputs from:
% Théa Ragon, Hannah Mark, Wasja Bloch, Thomas Lecocq

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{geomorphica}[2022 LaTeX2e document class]

\newif\if@review
\@reviewfalse
\DeclareOption{review}{\@reviewtrue}

\newif\if@anonymous
\@anonymousfalse
\DeclareOption{anonymous}{\@anonymoustrue}

\newif\if@titlepage
\@titlepagefalse
\DeclareOption{titlepage}{\@titlepagetrue}

\newif\if@breakmath
\@breakmathfalse
\DeclareOption{breakmath}{\@breakmathtrue}

\newif\if@languages
\@languagesfalse
\DeclareOption{languages}{\@languagestrue}

\newif\if@preprint
\@preprintfalse
\DeclareOption{preprint}{\@preprinttrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Review option by default
\if@preprint
\else
\@reviewtrue
\fi

\LoadClass[11pt,twoside,a4paper,onecolumn]{article}


\RequirePackage[headsep=0.7cm, top=2cm, bottom=2cm, left=2cm, right=2cm, footskip=0.7cm]{geometry}
\setlength{\columnsep}{0.8cm}
\RequirePackage[table]{xcolor}
% Geomorphica logo has a gradient of blues defined as follows (R,G,B) 
% First Color (0.00 offset) R,G,B = 0,0,43 (dark blue)
% Second color (0.05 offset) = 2,91,214
% Third color (0.85 offset) = 33,187,246
% Last color (1.00 offset) = 42,212, 255 (light blue)
% For submission teplate we will probably settle for all black and then make it prettier after acceptance. 
\definecolor{linkgeomorphica}{RGB}{0,0,0} % light-blue
\definecolor{geomorphicacolor1}{RGB}{0,0,0} % 
\definecolor{geomorphicacolor2}{RGB}{0,0,0} % 
\definecolor{geomorphicacolor3}{RGB}{0,0,0} % dark-blue
\definecolor{codebackcolor}{RGB}{243,243,243} %background shade
\RequirePackage[unicode, bookmarks=true, linkcolor=geomorphicacolor2, citecolor=geomorphicacolor2, hidelinks, hyperfootnotes=false]{hyperref}
\hypersetup{colorlinks,linkcolor=geomorphicacolor2}
\hypersetup{colorlinks,citecolor=geomorphicacolor2}
\hypersetup{colorlinks,urlcolor=geomorphicacolor2}

\RequirePackage{graphicx}
\RequirePackage{titlesec}
\RequirePackage{titling}
\RequirePackage{abstract}
\RequirePackage{fancyhdr}
\RequirePackage{bookmark}
\RequirePackage{caption} 
% \RequirePackage[round]{natbib}
\RequirePackage{doi}
%\RequirePackage{orcidlink}
\RequirePackage[noblocks]{authblk}
\setcounter{Maxaffil}{0}
\RequirePackage{datatool}
\RequirePackage{etoolbox}
\RequirePackage{comment}
\RequirePackage{physics}
\RequirePackage{listings}
\RequirePackage{changepage}
\RequirePackage{setspace}
\RequirePackage{xcolor}
% fonts and math
\RequirePackage{amsmath}
\if@breakmath
\RequirePackage{breqn}
\BeforeBeginEnvironment{dmath}{\begin{nolinenumbers}}
    \AfterEndEnvironment{dmath}{\end{nolinenumbers}}
\BeforeBeginEnvironment{dmath*}{\begin{nolinenumbers}}
	\AfterEndEnvironment{dmath*}{\end{nolinenumbers}}
% patches \eq@setnumber to use \refstepcounter instead of \stepcounter, from https://tex.stackexchange.com/questions/241118/autoref-to-dmath-from-breqn-package-generates-wrong-link-text
\patchcmd\eq@setnumber{\stepcounter}{\refstepcounter}{}{%
	\errmessage{Patching \noexpand\eq@setnumber failed}%
}
% break equations
\renewenvironment{equation}{%
	\begin{dmath}}{%
\end{dmath}}
\fi
\newcommand{\mathbfup}[1]{\mathord{\textnormal{\textbf{#1}}}}

\RequirePackage[mathlines]{lineno} %% loaded here because incompatibility with breqn
\if@review
% \linenumbers
\doublespacing
\fi

\if@languages
\RequirePackage{polyglossia}
\RequirePackage{fontspec}
\setmainlanguage[]{english}
\RequirePackage[autostyle=false, style=english]{csquotes}
%\RequirePackage[opentype,default,tabular,lining]{sourcesanspro}
%\RequirePackage[opentype,default,tabular,lining]{sourceserifpro}
%\RequirePackage[opentype,default,lining]{sourcecodepro}
\RequirePackage[regular]{sourcesanspro}
\RequirePackage[regular]{sourcecodepro}
\RequirePackage[default,regular]{sourceserifpro}
\RequirePackage[T1]{fontenc}
\else
\RequirePackage[regular]{sourcesanspro}
\RequirePackage[regular]{sourcecodepro}
\RequirePackage[default,regular]{sourceserifpro}
\RequirePackage[T1]{fontenc}
\RequirePackage[autostyle=false, style=english]{csquotes}
\fi

\newcommand{\sff}{\sourcesanspro}
\newcommand{\rmf}{\sourceserifpro}
\newcommand{\sflight}{\sourcesansprolight}
\newcommand{\rmlight}{\sourceserifprolight}
\urlstyle{sf}


%-------------------------------------------------------------------------------
%                Configuration for heading
%-------------------------------------------------------------------------------

% For credit
\newcommand{\printcreditifnotempty}{%
	\ifdim\DTLrowcount{credits}pt=0pt
	\else
	\vskip .5em
	\sffamily\footnotesize\raggedright\textcolor{black}{Author contributions:} \DTLforeach*{credits}{\Credrole=credrole, \Credauthor=credauthor}{\textcolor{black}{ \textit{ \Credrole}: \Credauthor.} }
	\fi
}

\pretitle{
            \begin{flushleft}
            \fontsize{21pt}{1em}\sffamily\bfseries\color{geomorphicacolor2}
	   }
\posttitle{
        	\end{flushleft}
            \vskip .2cm
          }
\preauthor{
            \lineskip 0.2cm%
            \begin{flushleft}
          }
\if@anonymous
	\postauthor{
                \end{flushleft}%
	          \vskip -.5em
	          \par
                }
\else
    \postauthor{
                \end{flushleft}
                \vskip -.5em
                \printcreditifnotempty
                \par
                }
\fi
\predate{}
\postdate{}
\date{}

\newcommand{\banner}{banner}

\def\doi#1{\def\@doi{#1}}
\doi{}

\renewcommand\maketitlehooka{%

\begin{nolinenumbers}

\vspace{-1.5cm} %\hspace{0.0}
\href{https://geomorphica.org/}{\includegraphics[width=\textwidth]{\banner}}

\end{nolinenumbers}
}

\renewcommand\maketitlehookd{%
\pagestyle{fancy}
\thispagestyle{plain}
}

%-------------------------------------------------------------------------------
%                Configuration for sections
%-------------------------------------------------------------------------------

\titleformat{\section}{\fontsize{14pt}{1em}\bfseries\sffamily\color{geomorphicacolor2}}{Tag \thesection}{1em}{}
\titleformat{\subsection}{\fontsize{12pt}{0.3em}\bfseries\sffamily\color{geomorphicacolor2}}{Station \thesubsection}{1em}{}
\titleformat{\subsubsection}{\fontsize{11pt}{0.1em}\bfseries\sffamily\color{geomorphicacolor2}}{\thesubsubsection}{1em}{}

\renewcommand{\normalsize}{\sffamily}

\setcounter{secnumdepth}{3}

\newenvironment{closing}[1]
{
\section*{#1}
}{
\vspace{0.3cm}}

\if@anonymous
\excludecomment{closing}
\fi

%-------------------------------------------------------------------------------
%                Configuration for header and footer
%-------------------------------------------------------------------------------

\pagestyle{fancy}
\fancyhf{}
\fancyfoot{}
\fancyfoot[R]{\sffamily\bfseries\footnotesize \thepage}
\renewcommand{\headrule}{}

\fancypagestyle{plain}{%
\renewcommand{\headrule}{}
}

%-------------------------------------------------------------------------------
%                Configuration for captions
%-------------------------------------------------------------------------------

\captionsetup{font={sf},
labelfont={bf,color=geomorphicacolor2},
labelsep=quad, 
justification=justified, 
singlelinecheck=false, oneside}


% equations
\if@breakmath
\renewcommand{\eqnumcolor}{\color{geomorphicacolor2}}
\renewcommand{\eqnumfont}{\sffamily}
\else
\renewcommand{\eqref}[1]{\textup{\eqreftagform@{\ref{#1}}}}
\let\eqreftagform@\tagform@
\def\tagform@#1{%
\maketag@@@{\color{geomorphicacolor2}\sffamily(\ignorespaces#1\unskip\@@italiccorr)}%
}
\fi

\renewcommand{\theequation}{\color{geomorphicacolor2}\arabic{equation}}

% end of geomorphica.cls 
