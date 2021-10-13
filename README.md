

- step1： 使用```get_sankey_input.pl```生成R包“network3D”绘图的输入文件

  ```perl get_sankey_input.pl config.txt output ```
  
  config.txt文件为界门纲目科属种的丰度信息
  

- step2：```sankey.plot.R```可视化 ```R -f sankey.plot.R```


- 可视化文件如下 [sankey-top15-species.html](https://github.com/wangpeng407/sankey3D-plot/blob/main/sankey-top15-species.html)

