#' @title gen_llosa
#' @description hack CA objet
#' @param BID CA objet to hack
#'
Llosa <- function(BID){
  BID$row$coord <-   cbind(BID$row$coord,0)
  BID$col$coord <- cbind(data.frame(BID$col$coord),0)
  colnames(BID$row$coord) <- c("Dim 1", "Dim 2")
  colnames(BID$col$coord) <- c("Dim 1", "Dim 2")
  BID

}



#' @title gen_llosa
#' @description plot the Llosa matrix
#' @param dataset the dataset to use
#' @param borne booleen do you want xlim and ylim
#' @param annotate booleen do you want annotation
#' @param annotatetext annotation text
#' @importFrom FactoMineR CA
#' @importFrom magrittr %>%
#' @importFrom tibble rownames_to_column
#' @importFrom reshape2 dcast
#' @importFrom tidyr separate
#' @importFrom ggrepel geom_text_repel
#' @importFrom stats reorder
#' @import ggplot2
#' @export
#' @examples
#' 
#' 
#' library(tetraclasse)
#' gen_avis(100) %>%
#'   prepare_base() %>%
#'   gen_llosa()
#'
#' 

gen_llosa <- function(dataset,borne=FALSE,annotate=TRUE,annotatetext = c("Secondaire"," Plus","Basique","Clef")){
  dataset %>% CA() %>% Llosa() -> res

  res$row$coord[,1,drop=FALSE] %>%
    as.data.frame() %>% rownames_to_column() %>%
    separate(rowname,c("critere","sens")) %>%
    dcast(critere~sens,value.var="Dim 1") ->to.plot

  to.plot[is.na(to.plot)]<-0 #peut etre pas le plus intelligent, mais de toutes facon cela n'arrivera jamais dans une vrai enquete.

  NN<-ggplot(data=to.plot ,aes(reorder(critere, negatif),negatif))+geom_bar(stat="identity")+coord_flip() +xlab("")
  PP<-ggplot(data=to.plot ,aes(reorder(critere, -positif),positif))+geom_bar(stat="identity")+coord_flip()+xlab("")



  to.plot$negatif <- to.plot$negatif-res$col$coord["negatif",1]
  to.plot$positif <- -(to.plot$positif-res$col$coord["positif",1])

  b<- max(abs(to.plot[,-1]),na.rm=TRUE)
  p<-ggplot(data=to.plot,aes(negatif,positif))+geom_point()+
    geom_hline(aes(yintercept=0))+geom_vline(aes(xintercept=0))+
    geom_text_repel(aes(label=critere))+theme_bw()
  annotations <- data.frame(
    xpos = c(-Inf,-Inf,Inf,Inf),
    ypos =  c(-Inf, Inf,-Inf,Inf),
    annotatetext = annotatetext,
    hjustvar = c(0,0,1,1) ,
    vjustvar = c(0,1.0,0,1))

  if (borne){
    p<-p  +ylim(-b,b)+xlim(-b,b)
    }

  if(annotate){
  p<-p +   geom_text(data = annotations, aes(x=xpos,y=ypos,hjust=hjustvar,
                                          vjust=vjustvar,label=annotatetext))
  }
print(p)

list(info=list(PP=PP,NN=NN),graph=p,coord=to.plot)


}



#' @title prepare_base
#' @description reshape the base
#'
#' @param satis_col satisfaction column name
#' @param base the base to reshape
#'
#' @examples
#' base <- gen_avis(150)
#' prepare_base(base)
#' @importFrom magrittr %>%
#' @importFrom reshape2 melt dcast
#' @importFrom tibble column_to_rownames
#' @importFrom tidyr unite
#' @importFrom dplyr filter
#' @export

prepare_base <- function(base,satis_col="satis"){


  base %>% melt(id.vars=satis_col) %>%
    filter(value != "NA")%>%
    unite("var",variable,value) %>%
    dcast(var~satis,value.var="var",fun.aggregate=length) %>%
    column_to_rownames("var")
}


#' @title gen_avis
#' @description generate some random data
#' @param N number of person
#' @examples
#' base <- gen_avis(50)
#' @export

gen_avis <- function(N){
 base<- data.frame(
    satis =    sample(0:10,N,replace=TRUE)  ,
    A =        sample(c("positif","negatif"),N,replace=TRUE,prob = c(0.1,0.9)),
    B =        sample(c("positif","negatif"),N,replace=TRUE,prob = c(0.3,0.7)),
    C =        sample(c("positif","negatif"),N,replace=TRUE,prob = c(0.6,0.4)),
    D =        sample(c("positif","negatif"),N,replace=TRUE,prob = c(0.7,0.3)),
    E =        sample(c("positif","negatif"),N,replace=TRUE,prob = c(0.1,0.9))

  )

 base$satis<- as.factor(base$satis>5)
 levels(base$satis)<-c("negatif","positif")
 base
}
