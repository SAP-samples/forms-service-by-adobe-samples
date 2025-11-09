import { defineConfig } from 'vitepress'
import lightbox from "vitepress-plugin-lightbox"
import { footnote } from "@mdit/plugin-footnote";
import { join } from "node:path";
import { promises as fs } from 'node:fs'
import type { LanguageInput, RawGrammar } from 'shiki'
const loadSyntax = async (file: string, name: string, alias: string = name): Promise<LanguageInput> => {
  const src = await fs.readFile(join(__dirname, file))
  const grammar: RawGrammar = JSON.parse(src.toString())
  return { name, aliases: [name, alias], ...grammar }
}

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Form Development Guide",
  description: "Kickstart your cloud document generation journey by example",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' }
    ],
    search: {
      provider: "local"
    },
    sidebar: [
      {
        text: 'Getting started',
        link: '/getting_started.md',
        items: [{
          text: "Connect Forms service by Adobe",
          link: "/getting_started/connect_foba.md"
        }, {
          text: "Connect to the sample repository",
          link: "/getting_started/abapgit.md"
        }]
      },
      { 
        text: "Samples",
        items: [
        {
          text: "Introduction custom form development",
          link: "/introduction.md"
        },
        {
          text: 'Build your first simple Form Data Provider',
          link: '/simple_example.md'
        },
        {
          text: 'Cinema Demo',
          link: '/cinema_demo.md'
        },
        ]
      },
      {
        text: 'Utilities',
        items: [
          {
            text: 'Preview your FDP / Form',
            link: '/preview_util.md'
          },
        ]
      },
      {
        text: 'Frequently asked questions / QA',
        link: '/faq.md'
      },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/SAP-samples/forms-service-by-adobe-samples' }
    ]
  },
  markdown: {
    languages: [
      await loadSyntax('syntaxes/abapcds.tmLanguage.json', 'abapcds'),
    ], 
    config: (md) => {
      // Use lightbox plugin
      md.use(lightbox, {});
      md.use(footnote, {})
    },
  },
})
