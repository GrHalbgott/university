print("Hello World!")
5 * 9
2 + 4.8
3^2
pi / 2


# NA = not available
# NaN = not a number
# NULL = empty
# is.na() = checks if value = NA

# ----------
# Übung 3

v <- c(1:5)
u <- c(6:10)

v + u
#[1] 7 9 11 13 15
u - v
#[1] 5 5 5 5 5
v * u
#[1] 6 14 24 36 50

u <- c(6:9)

# Warning message:
# In v + u : longer object length is not a multiple of shorter object length

v + u
#[1] 7 9 11 13 11
u - v
#[1] 5 5 5 5 1
v * u
#[1]6 14 24 36 30

x <- c("blue", 10, "green", 20)
is.character(x)
#[1] TRUE

rep(22, 6)

vec <- seq(-2, 4, 0.5)
vec[3] <- 17

dateseq <- seq(as.Date("01/01/2020", format = "%d/%m/%Y"), by = "month", length = 12)
class(dateseq)
dateseq[c(3, 5)] <- NA
factor(is.na(dateseq))
#[1] Levels: FALSE TRUE
dateseq[is.na(dateseq)] <- c(as.Date("31/01/2021"), as.Date("02/02/2022"))
factor(is.na(dateseq))
#[1] Levels: FALSE
length(is.na(dateseq))
#[1] 12

# ----------
# Übung 4

data(mtcars)
cars <- mtcars
str(cars)
#'data.frame':	32 obs. of  11 variables:
colnames(cars)
#[1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear" "carb"
# -------> DAFUQ cars$am <- as.factor(cars$am, labels = c("automatic", "manual"))

cars$model_name <- rownames(cars)
rownames(cars) <- c() # or NULL

cars_sub <- subset(cars, cars$cyl > 6 & cars$gear > 3, "model_name")

cars_new <- cars[c(1:3, 10:14), c("model_name", "mpg", "cyl", "wt", "gear")]

# ----------
# Übung 5

vec1 <- c(1:3)
vec2 <- c(4:6)
vec3 <- c(7:9)

mat <- cbind(vec1, vec2, vec3)
arr <- array(mat, dim = c(nrow(mat), ncol(mat), nrow(mat) * 4)) 
dim(arr)
# [1] 3 3 12

m <- matrix(1:6, 2, 3, byrow = T)
n <- matrix(1:6, 2, 3)
m * n

# -----------
# Übung 6

num_list <- list("Numbers yay", 
                 small = c(1:9),
                 large = c(10:1000, 50))

func <- function(day, code_working) {
  if (code_working == T & day == "Freitag")
    print("Best. Day. Ever. True & True")
  else if (code_working != T & day == "Freitag")
    print("Naja, immerhin ist Freitag :) False & True")
  else if (code_working == T & day != "Freitag")
    print("Fast! Wie doof, dass noch nicht Freitag ist. True & False")
  else if (code_working != T & day != "Freitag")
    print("Hello darkness my old friend... False & False")
}
