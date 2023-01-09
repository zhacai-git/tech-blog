---
title: nestjs项目开发和部署的一些总结
date: 2023-01-09 18:18:30
tags:
- tech
categories:
- 技术
---
还是食言了，本来想学SpringBoot开发的，没想到最近事情这么多耽误了。因为好久没写个人项目了，所以最近写了一个分布式服务器在线信息监测的程序。程序包含了节点端、服务端、用户端。

<!-- more -->

其中服务端是用nestjs开发的，因为我之前觉得纯express写后端很有toy-code的感觉。这次试用nestjs框架开发后确实感觉如此，虽然nestjs对于我来说有些抽象。

因为本人对于面向对象开发并不是很熟练，但是经过三天的奋战，在说明文档的帮助下，顺利的开发完成了本项目的服务端内容。

开发完成后我对于nestjs的印象还是很不错的，很多理念都是自SprintBoot借鉴过来的，这也算是变相加快了我学习SpringBoot的进程。

说完废话，开始总结。

**1.typeorm数据库实体的一些问题**

首先是配置连接属性的时候，如果需要typeorm根据 `entity`文件在数据库自动生成相应的表，需要在配置字段中 `synchronize`设置为 `true`，但是要注意这样会造成在修改实体文件字段后再次运行nestjs项目时，数据库被修改字段数据丢失。官方推荐使用migrate脚本来解决此问题，因为目前还没有遇到修改字段的问题，所以在此并不做记录。

另一个需要注意的点就是在使用 `createQueryBuilder`时，构造完查询后一定要再接 `.execute()`方法，我因为没加这个方法查了半天的BUG也不知道是哪里出问题了。

**2.nestjs项目打包问题**

使用nest-cli生成的项目中的 `package.json`中包含了build命令，该命令可以打包整个nestjs项目至 `dist`文件夹中。

但是用该方法生成的文件只是将项目中的ts文件编译为js文件，而所需依赖并未打包，导致项目若只把 `dist`文件夹中内容部署到服务器后因为缺少依赖无法运行。

初步的解决方案就是将整个项目文件除去 `.git`、`node_modules`等非工程文件夹后打包上传到服务器，在服务器端运行 `npm run build`后使用pm2进行进程管理。

目前的解决方案是根据[Nest项目部署的最佳方式 - 掘金 (juejin.cn)](https://juejin.cn/post/7065724860688760862)的内容，更改 `package.json`中的打包命令，添加 `--webpack`选项，同时在根目录下创建 `webpack.config.js`，并向其添加以下内容:

```javascript
const path = require("path");
const webpack = require("webpack");
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

module.exports = {
  entry: "./src/main",
  target: "node",
  // 置为空即可忽略webpack-node-externals插件
  externals: {},
  // ts文件的处理
  module: {
    rules: [
      {
        test: /\.ts?$/,
        use: {
          loader: "ts-loader",
          options: { transpileOnly: true }
        },
        exclude: /node_modules/
      }
    ]
  },
  // 打包后的文件名称以及位置
  output: {
    filename: "main.js",
    path: path.resolve(__dirname, "dist")
  },
  resolve: {
    extensions: [".js", ".ts", ".json"]
  },
  plugins: [
    // 需要进行忽略的插件
    new webpack.IgnorePlugin({
      checkResource(resource) {
        const lazyImports = [
          "@nestjs/microservices",
          "@nestjs/microservices/microservices-module",
          "@nestjs/websockets/socket-module",
          "cache-manager",
          "class-validator",
          "class-transformer"
        ];
        if (!lazyImports.includes(resource)) {
          return false;
        }
        try {
          require.resolve(resource, {
            paths: [process.cwd()]
          });
        } catch (err) {
          return true;
        }
        return false;
      }
    }),
    new ForkTsCheckerWebpackPlugin()
  ]
};
```

同时更改build命令后命令为 `nest build --webpack --webpackPath=./webpack.config.js`，这样会将所有的模块以及依赖都打包进一个main.js中，以此在服务器可以更加简单地进行部署和管理。当然，在一个大项目中我个人觉得还是第一种更加稳定靠谱。

最后更新：2023/01/09
