<script lang="ts">
    import Button, { Label } from '@smui/button'
    import { Span } from '@smui/common/elements'
    import { colorScheme, SchemeKind, darkTheme } from './stores'
    import './app.scss'
    import NavBar from './lib/NavBar.svelte'
    import Patcher from './lib/Patcher.svelte'
    import Description from './lib/Description.svelte'

    let scheme = window.localStorage.getItem('color-scheme')
    if (scheme == 'null' || scheme == 'undefined') scheme = 'System'
    $colorScheme =
        SchemeKind[scheme] !== undefined ? SchemeKind[scheme] : SchemeKind.System
    $: $darkTheme =
        $colorScheme === SchemeKind.Dark ||
        ($colorScheme === SchemeKind.System &&
            window.matchMedia('(prefers-color-scheme: dark)').matches)
    $: window.localStorage.setItem('color-scheme', SchemeKind[$colorScheme])

    let file: File
</script>

<svelte:head>
    {#if $darkTheme}
        <link rel="stylesheet" href="/theme-dark.css" />
    {/if}
</svelte:head>
<NavBar />

<main>
    <div id="paper" class="mdc-elevation--z4">
        <Description />

        <div id="file-selection">
            <input
                on:change={e => (file = e.currentTarget.files[0])}
                type="file"
                accept="application/zip"
                id="file"
            />
            <label for="file">
                <Button variant="outlined" component={Span}>
                    <Label>Choose File</Label>
                </Button>
                <span>{file === undefined ? 'No file chosen' : file.name}</span>
            </label>
        </div>

        <Patcher bind:file />
    </div>
</main>

<style lang="scss">
    main {
        padding: 5rem 1rem;
    }

    #paper {
        background-color: var(--clr-height-0-4);
        padding: 1rem 1.5rem;
        border-radius: 0.25rem;
        max-width: 40rem;
        margin: auto;
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    #file-selection {
        & > input {
            display: none;
        }
        & > label {
            display: flex;
            gap: 1rem;
            align-items: center;
        }
    }
</style>
