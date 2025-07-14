library(data.table);library(openxlsx)
setwd("/Users/yao/Desktop/挑战杯")
mydata <- read.csv('three.csv')

library(mice)#填补缺失值
dta2<-mice(mydata,seed=78)
dta <- complete(dta2,3)

# 对数据框中的变量进行对数变换
dta$Malaria <- log(dta$Malaria + ifelse(dta$Malaria == 0, 1e6, 0))
dta$Conflict <- log(dta$Conflict + ifelse(dta$Conflict == 0, 1e6, 0))
dta$pGDP <- log(dta$pGDP + ifelse(dta$pGDP == 0, 1e6, 0))
dta$ITN <- log(dta$ITN + ifelse(dta$ITN == 0, 1e6, 0))
dta$Light <- log(dta$Light + ifelse(dta$Light == 0, 1e6, 0))
dta$Population <- log(dta$Population + ifelse(dta$Population == 0, 1e6, 0))

pdata <- pdata.frame(filter, index = c("shapeID", "year"))

formula <- Malaria ~ Conflict+pGDP+ ITN+Light+Population

# 固定效应模型
fe <- plm(formula, data = pdata, model = "within")
# 随机效应模型
re <- plm(formula, data = pdata, model = "random")

# Hausman检验
phtest(fe, re)
#如果p值显著(<0.05)则选择固定效应模型
summary(filter)
fe_tw <- plm(Malaria ~ Conflict+pGDP+ ITN+Light+Population, Pdata, 
             index = c("shapeID", "year"),effect = "twoways",model = "within")
summary(fe_tw)


timem <- plm(Malaria ~ Conflict + pGDP+ ITN+Light+Population, Pdata, 
             index = c("shapeID", "year"),effect = "time",model = "within")
summary(timem)

invm <- plm(Malaria ~ Conflict + pGDP+ ITN+Light+Population, Pdata, 
            index = c("shapeID", "year"),effect = "individual",model = "within")
summary(invm)

# 比较个体固定效应和双向固定效应
pFtest(fe_tw, invm)
#如果检验结果显著(p值<0.05)说明更复杂的模型(双向固定效应)更好
# 比较时间固定效应和双向固定效应
pFtest(fe_tw, timem)

##################one-step GMM
library(plm)
library(dplyr)
library(broom)
library(sandwich)
library(lmtest)

# 构建 one-step 差分 GMM 模型
gmm_model_onestep <- pgmm(
  Malaria ~ lag(Malaria,1) +Conflict
  + pGDP+Light+lag(Population,1)+lag(ITN,1) |
    lag(Malaria, 2:3),
  data = Pdata,
  effect = "individual",
  model = "onestep", 
  transformation = "d"  # 差分 GMM
)

summary(gmm_model_onestep)

