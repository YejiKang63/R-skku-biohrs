## Previous drug history
library(parallel)

#source("code/inclusion.R")
data.asd  ## Inclusion data


code.drug <- list(
  Glucocorticoids = c("116401ATB", "140801ATB", "141901ATB", "141903ATB", "160201ATB", "170901ATB", "170906ATB", "193302ATB",
                      "193305ATB", "217034ASY", "217035ASY", "217001ATB", "243201ATB", "243202ATB", "243203ATB"),
  Aspirin = c("110701ATB", "110702ATB", "111001ACE", "111001ATE", "489700ACR", "517900ACE", "517900ATE", "667500ACE"),
  Clopidogrel = c("136901ATB", "492501ATB", "495201ATB", "498801ATB", "501501ATB", "517900ACE", "517900ATE", "667500ACE")
)


# info.prevmed <- mclapply(code.drug, function(x){
#   merge(data.asd,
#         m60[GNL_NM_CD %in% x][order(MDCARE_STRT_DT), .SD[1], keyby = "RN_INDI"][, .(RN_INDI, inidate = MDCARE_STRT_DT)],
#         by = "RN_INDI", all.x = T)[, ev := as.integer(Indexdate >= as.Date(as.character(inidate), format = "%Y%m%d"))][, ev := ifelse(is.na(ev), 0, ev)][]$ev
# }, mc.cores = 3) %>% do.call(cbind, .)
# colnames(info.prevmed) <- paste0("Prev_", names(code.drug))

# rolling merge in 365 days 위의 결과와 같게 하려면 roll=Inf, 365일 내로 보려면 roll=365
info.prevmed <- mclapply(code.drug, function(x){
  data.asd[, MDCARE_STRT_DT := Indexdate]
  dt <- m60[GNL_NM_CD %in% x][, MDCARE_STRT_DT := as.Date(as.character(MDCARE_STRT_DT), format = "%Y%m%d")][, .(RN_INDI, MDCARE_STRT_DT, inidate = MDCARE_STRT_DT)] 
  dt[, .SD[1], keyby = c("RN_INDI", "MDCARE_STRT_DT")][data.asd, on = c("RN_INDI", "MDCARE_STRT_DT"), roll = 365][, ev := as.integer(!is.na(inidate))][]$ev
}, mc.cores = 3) %>% do.call(cbind, .)
colnames(info.prevmed) <- paste0("Prev_", names(code.drug))
