data1=readtable('RR secondary complete recipe v208c ht2a try 2 FeatureMeas.csv');
data2=readtable('RR tertiary complete recipe v208c ht2a try 2 equ D image.csv');
figure()
f_sizedisthist(data1.EquivalentDiameter_nm_,data1.AreaFraction___./100,0.5,'nm')
hold on
f_sizedisthist(data2.EquivalentDiameter_nm_,data2.AreaFraction___./100,0.5,'nm')
legend('Secondary','Tertiary')
max(data1.EquivalentDiameter_nm_)


data3=readtable('Ioannis'' thread 013 RR working complete rcp 2 FeatureMeas.csv');
figure()
f_sizedisthist(data3.EquivalentDiameter_nm_,data3.AreaFraction___./100,0.5,'nm')
hold on
f_sizedisthist(data1.EquivalentDiameter_nm_,data1.AreaFraction___./100,0.5,'nm')
legend('Thread 013 Secondary','ht2a Secondary')