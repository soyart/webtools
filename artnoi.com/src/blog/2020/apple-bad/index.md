Aug 24, [2020](/blog/2020/)

Last edited: September 2020

# Why you should NOT use Apple computers (sans iOS devices) for work

I have been a life-long macOS user ever since getting my first laptop back in 2008. At the time, I admired the Apple innvoation that enabled me to have productivity advantages compared to my peers who used PC laptops. The advantages Apple used to have include:

**Apple exclusive advantages**

- **Apple trackpad** (Now the only good stuff in MacBooks - in fact, it is so good Apple released standalone trackpads)
- **Apple MagSafe** (Now replaced by USB-C ports)
- **Robustness of macOS** (Much more unreliable in recent versions, and even worse with the T2 chip)
- **iOS integration**

**Non-exclusive advantages**

- **Great screens** in almost all laptops (Others now have comparable or better screens than Retina display)
- **2-in-1 3.5mm port** (TOSLINK + analog audio I/O)
- **100% PCIe flash storage** in laptops

We can see that today, _Apple competitors have designed superior laptops in almost every way except for the trackpad_ and iOS integration. Here I will rant about the key consideration that made me think Apple computers, especially laptops, are garbage when compared to Lenovo ThinkPads. This artlcle attempts to criticize the _Pro_ line of Apple laptops from a perspective of a business user.

## Apple doesn't repair Macs - be it a Mac Pro or a MacBook Air

Apple is known for their replacement policy, where they will offer to replace your failed devices with refurbished units at a (large) fraction of full device price. This irresponsible mindset on its own does not have any significant implications to business users, but when coupled with a number of Apple-specific practices (like insisting on flawed hardware designs, or obvious planned obsolecense), is really bad for business users.

## Apple doesn't care about user data

Unlike other sane laptop makers who use off-the-shelf parts for storage on their laptops (e.g. SATA disks, mSATA SSDs, M.2 SSDs, or both), Apple has been known for their decision to use ultra-fast _custom_ proprietary NAND flash storage in their computers. Apple chooses to embed the proprietary flash storage chips right on the motherboard (much like their memory chips), and so the chips are controlled by the on-board custom flash storage controllers (which on modern Mac platforms are on the T2 co-processor). Sure, high performance and high endurance NAND flash is a good thing, but the fact that now it comes in proprietary package without industry standard means that it is very hard to recover the data from a failed board, even if it's unencrypted. Apple's NAND flash is nothing like your conventional SATA or NVMe SSDs which come complete with their own controller so you can simply put in any other working computers to (attempt to) recover the data.

> Apple's highly integrated flash controller provides data-at-rest security and data encryption. The encryption key they use to is however partly derived from the hardware uniqute identifier in recent Macs. This means that different boards can NOT read encrypted data from other other boards. In short, even if you manage to successfully interface with the NAND flash chip, you will lack the encryption key(s) needed to decrypt your data. I have lost complete interest in Apple products after learning that the T2 is used in all recent Mac lineup.

This custom storage decision, coupled with hardware key encryption, and the fact that Apple hates repairs, means that if your Mac laptops (also current iMac and Mac mini lines) were to fail due to any stupid reason, Apple will simply offer to swap out the board and call it a day. This takes all the data with it - and there is no way for an average person to recover the data. Matters were made exacerbated [after the T2 chip was added](https://www.apple.com/euro/mac/shared/docs/Apple_T2_Security_Chip_Overview.pdf), there is currently no official or practical way to recover data from a dead motherboard. Even Apple's engineers can not and should not be able to do that.

Had Apple chosen off-the-shelf SSDs for their designs, it would have been a thoudsand times easier for us normal people to recover the data from a dead board (and also replace the system storage), even if Apple refused to do it.

## Bad hardware designs: weak construction and subpar cooling.

Apple chooses Aluminum alloy for their laptop cases, which although looks really good, is really a bad material choice for laptop enclosure. A solid case may feel strong, but it will fail (i.e. break) upon big shocks, and Apple unibody design ensures that the case will be totally ruined after a drop. The laptop chassis is also poorly reinforced, and poorly designed. Though the case is strong metal, the hinge is made from weak plastic that is made to nowhere near the ThinkPad hinges (ThinkPads have metal hinges and composite body). Apple also use the case as the wireless antenna, yet the 2016-2018 MacBook Pro still suffers from wireless connectivity issues.

> **Some Apple users claim that Apple was wise to choose metal as laptop enclosure to help dissipate heat. This is totally stupid. What you want is a good internal copper heatsink to be effecient enough to do its job, a well done thermal paste (which is something Apple still can't do properly), and enough fans to move sufficient airflow in the machine to do the cooling on your CPU/GPU, not the metal case. To think that a metal laptop case will cool the CPU is to think like those idiots who try to cool their car engine by pouring water on to the hood and then touches it and say "Oh hey it she is cooler now!".**

Having owned 4 of Apple laptops (3 of them MacBook Pro) in the past decade, I highly doubt Apple's thermal designs are efficient. macOS's reluctance to spin up the fans (to maintain the image of a cool and quiet workstation) also worsens the situation. Remember that Apple designs their laptop to be quiet not cool, and that heat is the mortal enemy of computers.

## Their designs are too consumer-oriented, not for business

Apple fanboys I know tend to boast that their machines are well designed for what they do (which usually is Safari plus MS Office 365). They talk about superior battery life, Retina screens, thin-and-light designs, and of course the trackpad. None of this matter to me when deciding on a professional business laptop. When you use a professional business laptop, you expect great keyboard (which recent Apple laptops lack), plentiful USB-A ports for your mouse and peripherals (hence the no-need for trackpad), and **most importantly you want reliability**. Who cares if it is 20 gram lighter or 2mm slimmer if you can't service the thing at all. And seriously, which professional cares if their _Pro_ machine is super thin and light.

> It's like designing a luxury sports car with excessive obsession on minimizing NVH and self-parking tech, yet very little attention is given to reliability on the track (sometimes even track performacnce).

## Reliability explored

If the machine is servicable and modular enough, we consider it reliable, as we can swap out failed parts and then continue working right away. Apple tries to _reinvent_ reliability with a lot of _Wow!_ factors. For example they introduced very large battery so that their users can work all day, and SSD-by-default so that their machine is not prone to HDD-related data corruption. But these false reliability factors are not reliable **in the long term**.

> **We all know that hardware eventually dies**, so the most reliable laptop is one that is highly modular and easily servicable. Apple laptops look reliable during the first year due to its high-tech components, but they all come as a single package - you can not _easily_ replace a failed part.

This means that if the machine decided it would fail in the middle of important tasks, you are screwed - you can NOT fix the system right away. This is in stark contrast to other business laptops. Encountering a failed disk? On a Mac you and your data are screwed. On business machines you might replace the disk and not the whole board, and may later attempt to recover yout data. A degraded (expanded) battery? On a Mac, if the model is eligible for battery replacement, you will have to send it in and wait a few business days to get sorted out. Well, we can replace that dead battery in a few seconds on Lenovo ThinkPads. We (as the serious laptop users) don't care much about the built-in battery life if we can replace battery on-the-fly.

## Lastly, they don't let you do what you want with your hardware

You own the hardware. You bought it from the store. You should be able to do anything with it, and the manufacturer should do anything in their power to provide you with the documentation you needed. In the past, computers used to come with block diagrams that explain how each internal part works, how you can service the machine, etc. Today Apple actively tries to prevent you from learning more about servicing your system. They also did not try at all when it comes to free and open source operating system support on their hardware. The result is that you can not do what you want to do with the product you bought and own. Oh, so you are a professional? So what happens if you want to train AI or do something you can't do on macOS and Windows? Or what if you want to clean your clogged only cooling fan that was already underperforming when clean? Nah man, not gonna happen without voiding warranty.

## Conclusion

> After considering all these points, my conclusion is that you should not use Apple's late products if you value reliability and servicability, or if you simply appreciate longetivity of a product. **Apple has drifted too far to ensure that their products are consumable and will eventually die**. Consider Apple Watches and AirPods - in the not-so-distant past, these types of products (wristwatches and headphones) were evaluated based heavily on their reliability. Think of Rolex and Sennheiser products. And now look at Apple's watch and headphone offerings.

## Who is MacBooks good for?

Unless you are a creative professional who depends on macOS-only creative software, or a university student who needs to access notes on the iPad quickly, I don't see a good reason to spend that much money on a fashion laptop. A non-technical person is also advised to use a Mac, because macOS is more secure and easier to use than Windows by default.

## Alternatives to Apple laptops

Lenovo ThinkPad X, T, W, and P series of laptops are very good Apple laptop replacement. They are premium business laptops trusted by those who actually use their computers to work, like the engineers and computer programmers. ThinkPads will satisfy MacBook ex-users as they have many things in common, e.g. a strong cult following, decade-long industrial design language, and best-in-class navigation (the Lenovo TrackPoint vs Apple trackpad). The plus sides for ThinkPads include excellent free and open-source OS support, super nice hardware maintenace manual, and most importantly better hardware design overall.
