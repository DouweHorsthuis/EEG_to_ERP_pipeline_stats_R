install.packages("x")

#uploads libraries 
library(x)
library(y)
library(z)

#cleans environment
rm(list=ls())
#no scientific notations
options(scipen=999)

##############

#imports data from .txt file
exr=read.table("tt.txt", sep="\t", header=TRUE)
#defines column names
colnames(exr)=c("a", "b","c","d")  

#creates factors
exr$subj=as.factor(exr$a)
exr$group <- factor (exr$b, levels = c(1:4), labels = c("b1", "b2", "b3", "b4"))

#checks
sort(unique(exr$a))
length(unique(exr$a))
sort(unique(exr$b))
sort(unique(exr$c))
str(exr)

#creates summary-mean and standard deviation
summaryBy(d ~ b, data=exr, FUN=c(length,mean,sd))

#randomly selects 200 trials per subject 
reducedexr <- exr %>% group_by(a) %>% sample_n(size = 200)

#plots violin + boxplot
exrPlot <- ggplot(reducedexr, aes(x = b, y = d, color=b, fill=b)) 
exrPlot <- exrPlot + theme(legend.key.size = unit(1, "cm"))
exrPlot <- exrPlot + geom_violin (lwd=2, alpha = 0.5, position=position_dodge(1), color=NA) 
exrPlot <- exrPlot + geom_boxplot(alpha = 0.5, width=0.1, outlier.shape = NA)
exrPlot <- exrPlot + stat_summary(fun.y=mean_sdl, geom="pointrange", size=3, color="black", position=position_dodge(1), alpha = 0.8)
exrPlot <- exrPlot + scale_color_manual(values=c("#006600", "chartreuse3", "deeppink", "palevioletred1")) 
exrPlot <- exrPlot + scale_fill_manual(values=c("#006600", "chartreuse3", "deeppink", "palevioletred1"))  
exrPlot <- exrPlot + labs(y = expression(paste("example")))
exrPlot <- exrPlot + theme_minimal()
exrPlot <- exrPlot + theme(axis.line = element_line(colour = "grey"),
                           panel.grid.major = element_blank(),
                           panel.grid.minor = element_blank(),
                           panel.border = element_blank(),
                           panel.background = element_blank())
exrPlot <- exrPlot + theme(legend.position = "none")
exrPlot <- exrPlot + theme(text = element_text(family="sans", size=28))
exrPlot <- exrPlot + scale_y_continuous(limits = c(-30,50))
exrPlot

#mixed-effects models

#creates dataset with only two of the groups (b3 and b4)
jkl <- subset(reducedexr, b!="b1" & b!="b2") 

#d is the dependent variable, b is a fixed factor, a and c are random factors
model1.0 = lmer(d~b+(1|a)+(1|c), data = jkl, REML=FALSE)
summary(model1.0)
