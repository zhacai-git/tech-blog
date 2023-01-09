---
title: 在electron踩的坑(持续更新)
date: 2022-10-01 20:15:35
tags:
- tech
categories:
- 技术
---
最近在搞一个基于electron的客户端，具体内容暂且不表，下面是近一阵遇到的各种问题以及部分的解决方案。

<!-- more -->

**1.窗口大小设置不符合预期**

我只能说这个问题，在new BrowserWindow中给定的width和height不太像按照实际像素来的，更像是一种比例关系，这点就需要自己调了，很奇怪，没找到解决办法。

**2.自定义标签栏，标签栏上元素无法点击的问题**

这个问题主要在于为了使electron知道这是个标题栏（可拖动），需要在CSS中配置

```css
-webkit-app-region: drag;
```

但这会导致整个标签栏变成可拖动区域，使得鼠标的点击操作不生效了。

目前我找到的解决方案，也是我认为较为完美的，即设置需要点击的元素CSS：

```css
-webkit-app-region: no-drag;
```

即可解决问题。

这破问题卡了我一个多小时，打死也想不到是因为这个造成的，甚至一度怀疑Vue的v-on:click失效了，晕了。

**3.在主进程中引用绝对路径造成的报错**
因为需要自定义一个托盘栏的图标，需要在background.ts中new Tray时给定一个路径。
我在这里引用绝对路径以后就直接报错无法启动了。
目前使用的解决方案是在项目根目录下创建vue.config.js后添加:

```javascript
module.exports = {
  pluginOptions: {
    electronBuilder: {
      nodeIntegration: true
    }
  }
}
```

目前项目还远没有结束，结束前遇到的新坑都会在这里发的。

感觉写桌面客户端好爽，不用考虑适配和响应式，长宽一锁定，随便定位元素。很舒服，比浏览器开发要省事很多。

2023-1-9更新

最近自己写了一个小工具用于可视化监控各个服务器的状态，安全起见前端只设计了客户端，不做公网的网页端了，这次在应用图标设置、打包方面遇到了一些坑，在这里续更一下。

首先要吐槽的就是这玩意开发真吃内存啊，全栈开发，两个IDE一开，再开个浏览器，网易云啥的，16G内存直接拉满，WebStorm直接报low memory了，前所未见。考虑升级内存了。

**4.应用图标设置无效**

在用vue-electron-builder插件生成的工程中，background.ts是electron的入口。其中应用程序图标的是在 `createWindow()`函数中的 `new BrowserWindow()`中设置的，具体如下。

```javascript
async function createWindow() {
  // Create the browser window.
  win = new BrowserWindow({
    width: 1200,
    height: 600,
    maximizable: false,
    minimizable: true,
    resizable: false,
    useContentSize: true,
    frame: false,
    webPreferences: {
      nodeIntegration: (process.env
          .ELECTRON_NODE_INTEGRATION as unknown) as boolean,
      contextIsolation: !process.env.ELECTRON_NODE_INTEGRATION
    },
    icon: path.join(__dirname,'../src/assets/logo.png')
  })
  ....其余的代码
}
```

其中的 `icon`字段就是应用图标，通俗来讲就是在系统任务栏以及在windows系统中应用头部左上角的Logo位置的图标（如果使用了默认头部，在这个示例里就没有）。

如果按照上面的设置没有显示出来的话，那么大概率就是路径错了，这个挺坑的，实际运行的 `__dirname`环境变量实际为dist目录，故这里使用了 `../`来切换到上级目录后再获取。

**5.ico图标的问题**

这个问题纯属自己没有常识了，看到应用打包时要用ico图标而不是png图标，直接就把png后缀改为ico了，打包直接报错，后来找到一个转换网站才解决。

同时 `nsis`打包时需要ico的大小是>=256*256的，这点一定要注意，否则会报错无法打包。

**6.electron:build 配置文件的问题**

这玩意挺坑的，网上在写build配置文件的时候都是直接往package.json里面一扔就完事了，我这么写直接报 `InvalidConfigurationError: ‘build’ in the application package.json is not supported since 3.0 anymore. Please move ‘build’ into the development package.json`。

解决方案就是继续在第三点中提到的，在项目根目录下创建 的 `vue.config.js`中：

```javascript
module.exports = {
  runtimeCompiler: true,
  pluginOptions: {
    electronBuilder: {
      builderOptions: {
        // build配置在此处
        // options placed here will be merged with default configuration and passed to electron-builder

      }
    },
  },
};
```

这么写，和json语法一致，不要去掉每个选项的双引号，**同时 `build`就不用写了，直接写里面的选项**，这是github issue([Edit Built Installer Filename · Issue #171 · nklayman/vue-cli-plugin-electron-builder (github.com)](https://github.com/nklayman/vue-cli-plugin-electron-builder/issues/171))上的一段示例：

```javascript
pluginOptions: {
  electronBuilder: {
    builderOptions: {
      "extraResources": [
        {
          "from": "./extraResources/",
          "to": "extraResources",
          "filter": [
            "**/*"
          ]
        }
      ]
    },
  }
},
```

**7.nsis打包输出文件的问题**

如果自行更改了 `builderOptions`中 `nsis`字段的 `artifactName`名称的话，一定要加上.exe，否则应用打包出来是没有文件扩展名的，无法执行。

electron-builder官网说法： `artifactName` String | “undefined” - The [artifact file name template](https://www.electron.build/configuration/configuration#artifact-file-name-template). Defaults to `${productName} Setup ${version}.${ext}`

链接：[NsisOptions - electron-builder](https://www.electron.build/generated/nsisoptions)

最后更新:2023/01/09
