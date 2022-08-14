<script lang="ts">
    import Button, { Label } from '@smui/button'
    import CircularProgress from '@smui/circular-progress'
    import { onMount } from 'svelte'
    import JSZip from 'jszip'
    import Jimp from 'jimp/browser/lib/jimp'
    import { saveAs } from 'file-saver'

    export let file: File = undefined

    let patchButtonDisabled: boolean
    onMount(() => (patchButtonDisabled = true))
    $: patchButtonDisabled = file === undefined

    let step = ''

    const dyeColors: string[] = [
        '',
        '_black',
        '_blue',
        '_brown',
        '_cyan',
        '_gray',
        '_green',
        '_light_blue',
        '_light_gray',
        '_lime',
        '_magenta',
        '_orange',
        '_pink',
        '_purple',
        '_red',
        '_white',
        '_yellow',
    ]

    async function patch() {
        step = 'unpack zip'
        const pack = await JSZip.loadAsync(file)

        // shulker boxes
        for (const color of dyeColors) {
            step = `read shulker${color}.png`
            let buf = await pack
                .file(`assets/minecraft/textures/entity/shulker/shulker${color}.png`)
                ?.async('uint8array')
            if (buf === undefined) continue
            const img = await Jimp.read(Buffer.of(...buf))
            const scale = img.getWidth() / 64

            step = `patch shulker${color}.png`
            img.blit(img, 32 * scale, 0, 32 * scale, 28 * scale, 16 * scale, 16 * scale)
            img.blit(img, 0, 24 * scale, 0, 44 * scale, 64 * scale, 8 * scale)

            img.crop(0, 0, 64 * scale, 32 * scale)

            step = `write closed_shulker${color}.png`
            buf = await img.getBufferAsync(Jimp.MIME_PNG)
            if (buf === undefined) continue
            pack.file(
                `assets/enchantedshulkers/textures/entity/shulker/closed_shulker${color}.png`,
                buf,
            )
        }

        // ender chest
        step = 'read ender.png'
        let buf = await pack
            .file('assets/minecraft/textures/entity/chest/ender.png')
            ?.async('uint8array')
        if (buf !== undefined) {
            const img = await Jimp.read(Buffer.of(...buf))
            const scale = img.getWidth() / 64

            step = 'patch ender.png'
            img.blit(img, 14 * scale, 0, 14 * scale, 19 * scale, 14 * scale, 14 * scale)
            img.blit(img, 0, 59 * scale, 0, 14 * scale, 56 * scale, 5 * scale)
            img.blit(img, 0, 14 * scale, 0, 33 * scale, 56 * scale, 10 * scale)
            img.blit(img, 0, 23 * scale, 0, 59 * scale, 56 * scale, 5 * scale)

            img.crop(0, 0, 64 * scale, 32 * scale)

            step = 'write closed_ender.png'
            buf = await img.getBufferAsync(Jimp.MIME_PNG)
            if (buf !== undefined) {
                pack.file(
                    'assets/enchantedshulkers/textures/entity/chest/closed_ender.png',
                    buf,
                )
            }
        }

        step = 'save file'
        const blob = await pack.generateAsync({ type: 'blob' })
        saveAs(blob, `${file.name.replace(/\.zip$/, '')}-patched.zip`)
        step = ''
    }
</script>

<div id="patcher">
    <Button variant="raised" bind:disabled={patchButtonDisabled} on:click={patch}>
        <Label>Patch</Label>
    </Button>

    <CircularProgress
        indeterminate
        id="patch-spinner"
        class={step === '' ? 'hidden' : ''}
    />
    <code id="step">{step}</code>
</div>

<style lang="scss">
    #patcher {
        display: flex;
        align-items: center;
        gap: 1rem;
    }

    #step {
        color: var(--clr-text-hint);
    }

    :global #patch-spinner {
        &.hidden {
            opacity: 0;
        }
    }
</style>
