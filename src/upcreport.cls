\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{upcreport}[2021/10/30 Universidad Peruana de Ciencias Aplicadas themed article class]

\LoadClassWithOptions{article}

\RequirePackage[margin=1in]{geometry}
\RequirePackage{graphicx}
% \RequirePackage{mathptmx} % Commented until it can work with lualatex
\RequirePackage[spanish, calc]{datetime2}

\DeclareRobustCommand{\setimagesfolder}[1][images/]{
  \graphicspath{{#1}}
}

\DeclareRobustCommand{\settitle}[1]{
  \DeclareRobustCommand{\thetitle}{#1}
}
\DeclareRobustCommand{\settheme}[1]{
  \DeclareRobustCommand{\thetheme}{#1}
}
\DeclareRobustCommand{\setcoursename}[1]{
  \DeclareRobustCommand{\thecoursename}{#1}
}
\DeclareRobustCommand{\setcoursecode}[1]{
  \DeclareRobustCommand{\thecoursecode}{#1}
}
\DeclareRobustCommand{\setcoursegroup}[1]{
  \DeclareRobustCommand{\thecoursegroup}{#1}
}
\DeclareRobustCommand{\setteacher}[1]{
  \DeclareRobustCommand{\theteacher}{#1}
}  
\DeclareRobustCommand{\setauthor}[1]{
  \DeclareRobustCommand{\theauthor}{#1}
}

\DeclareRobustCommand{\maketitlepage}{
  \begin{figure}[h]
    \centering
    \includegraphics[width=0.5\textwidth]{logo-upc}
  \end{figure}
  
  \begin{center}
    \Large\textbf{\thetitle}
  \end{center}
  
  \vspace{1cm}
  
  \begin{itemize}
    \item \textbf{Tema:} \thetheme
    \item \textbf{Curso:} \thecoursename (\thecoursecode)
    \item \textbf{Sección:} \thecoursegroup
    \item \textbf{Profesor:} \theteacher
    \item \textbf{Integrantes:} \theauthor
  \end{itemize}
  
  \vspace{5cm}
  
  \begin{center}
    \DTMspanishmonthname{\month}, \the\year{}
  \end{center}
}
