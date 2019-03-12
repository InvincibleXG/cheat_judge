# cheat_judge
一个用 Ruby 编写的代码查重算法，核心算法为 k-grams + winnowing，不足之处很多，跪求大佬指点！

调用流程是先将submission对象中的source_code(学生提交的源代码)，取出来放到一个 source_code_list 中然后进行两两计算文档指纹的位置与哈希值，作为指纹进行重复度似然计算。(准确度一般，但可调参)

算法核心是将过滤了一些无关符号和空格的源代码进行变量替换与压缩，选取一个 k 值走窗口切分 k 元文法块shingle，再将 shingle 的 roll_hash 求出，组成一个 shingle_hash_array，最后利用 winnowing 算法截取这些 随机position => hash 的键值对作为文档的指纹特征。有什么可以优化的地方希望大佬多多指正！
